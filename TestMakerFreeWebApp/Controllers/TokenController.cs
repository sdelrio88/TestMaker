using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using System.Reflection.Metadata;
using TestMakerFreeWebApp.ViewModels;
using TestMakerFreeWebApp.Data;
using Microsoft.AspNetCore.Identity;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System.Net.Http;
using Newtonsoft.Json;

namespace TestMakerFreeWebApp.Controllers
{
    public partial class TokenController : BaseApiController
    {
        #region Private Members
        #endregion Private Members

        #region Constructor
        public TokenController(
            ApplicationDbContext context,
            RoleManager<IdentityRole> roleManager,
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            IConfiguration configuration
            )
            : base(context, roleManager, userManager, configuration)
        {
            SignInManager = signInManager;
        }
        #endregion

        #region Properties
        protected SignInManager<ApplicationUser> SignInManager { get; private set; }
        #endregion

        [HttpPost("Auth")]
        public async Task<IActionResult> Auth([FromBody]TokenRequestViewModel model)
        {
            // return a generic HTTP Status 500 (Server Error)
            // if the client payload is invalid.
            if (model == null) return new StatusCodeResult(500);

            switch (model.grant_type)
            {
                case "password":
                    return await GetToken(model);
                default:
                    // not supported - return a HTTP 401 (Unauthorized)
                    return new UnauthorizedResult();
            }
        }

        [HttpPost("Facebook")]
        public async Task<IActionResult> Facebook([FromBody]ExternalLoginRequestViewModel model)
        {
            try
            {
                var fbAPI_url = "https://graph.facebook.com/v2.10/";
                var fbAPI_queryString = String.Format(
                    "me?scope=email&access_token={0}&fields=id,name,email",
                    model.access_token);
                string result = null;

                // fetch the user info from Facebook Graph v2.10
                using (var c = new HttpClient())
                {
                    c.BaseAddress = new Uri(fbAPI_url);
                    var response = await c
                        .GetAsync(fbAPI_queryString);
                    if (response.IsSuccessStatusCode)
                    {
                        result = await response.Content.ReadAsStringAsync();
                    }
                    else throw new Exception("Authentication error");
                };

                // load the resulting Json into a dictionary
                var epInfo = JsonConvert.DeserializeObject<Dictionary<string, string>>(result);
                var info = new UserLoginInfo("facebook", epInfo["id"], "Facebook");

                // Check if this user already registered himself with this external provider before
                var user = await UserManager.FindByLoginAsync(
                    info.LoginProvider, info.ProviderKey);
                if (user == null)
                {
                    // If we reach this point, it means that this user never tried to logged in
                    // using this external provider. However, it could have used other providers 
                    // and /or have a local account. 
                    // We can find out if that's the case by looking for his e-mail address.

                    // Lookup if there's an username with this e-mail address in the Db
                    user = await UserManager.FindByEmailAsync(epInfo["email"]);
                    if (user == null)
                    {
                        // No user has been found: register a new user using the info 
                        //  retrieved from the provider
                        DateTime now = DateTime.Now;
                        var username = String.Format("FB{0}{1}",
                                epInfo["id"],
                                Guid.NewGuid().ToString("N")
                            );
                        user = new ApplicationUser()
                        {
                            SecurityStamp = Guid.NewGuid().ToString(),
                            // ensure the user will have an unique username
                            UserName = username,
                            Email = epInfo["email"],
                            DisplayName = epInfo["name"],
                            CreatedDate = now,
                            LastModifiedDate = now
                        };

                        // Add the user to the Db with a random password
                        await UserManager.CreateAsync(user,
                            DataHelper.GenerateRandomPassword());

                        // Assign the user to the 'RegisteredUser' role.
                        await UserManager.AddToRoleAsync(user, "RegisteredUser");

                        // Remove Lockout and E-Mail confirmation
                        user.EmailConfirmed = true;
                        user.LockoutEnabled = false;

                        // Persist everything into the Db
                        DbContext.SaveChanges();
                    }
                    // Register this external provider to the user
                    var ir = await UserManager.AddLoginAsync(user, info);
                    if (ir.Succeeded)
                    {
                        // Persist everything into the Db
                        DbContext.SaveChanges();
                    }
                    else throw new Exception("Authentication error");
                }

                // create & return the access token
                var t = CreateAccessToken(user.Id, user.UserName);
                return Json(t);
            }
            catch (Exception ex)
            {
                // return a HTTP Status 400 (Bad Request) to the client
                return BadRequest(new { Error = ex.Message });
            }
        }


        private async Task<IActionResult> GetToken(TokenRequestViewModel model)
        {
            try
            {
                // check if there's an user with the given username
                var user = await UserManager.FindByNameAsync(model.username);
                // fallback to support e-mail address instead of username
                if (user == null && model.username.Contains("@"))
                    user = await UserManager.FindByEmailAsync(model.username);

                if (user == null
                    || !await UserManager.CheckPasswordAsync(user, model.password))
                {
                    // user does not exists or password mismatch
                    return new UnauthorizedResult();
                }

                // create & return the access token
                var t = CreateAccessToken(user.Id, model.username);
                return Json(t);
            }
            catch (Exception ex)
            {
                return new UnauthorizedResult();
            }
        }


        private TokenResponseViewModel CreateAccessToken(string userId, string username)
        {
            DateTime now = DateTime.UtcNow;

            // add the registered claims for JWT (RFC7519).
            // For more info, see https://tools.ietf.org/html/rfc7519#section-4.1
            var claims = new[] {
                new Claim(JwtRegisteredClaimNames.Sub, userId),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim(JwtRegisteredClaimNames.Iat,
                    new DateTimeOffset(now).ToUnixTimeSeconds().ToString())
                // TODO: add additional claims here
            };

            var tokenExpirationMins =
                Configuration.GetValue<int>("Auth:Jwt:TokenExpirationInMinutes");
            var issuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(Configuration["Auth:Jwt:Key"]));

            var token = new JwtSecurityToken(
                issuer: Configuration["Auth:Jwt:Issuer"],
                audience: Configuration["Auth:Jwt:Audience"],
                claims: claims,
                notBefore: now,
                expires: now.Add(TimeSpan.FromMinutes(tokenExpirationMins)),
                signingCredentials: new SigningCredentials(
                    issuerSigningKey, SecurityAlgorithms.HmacSha256)
            );
            var encodedToken = new JwtSecurityTokenHandler().WriteToken(token);

            return new TokenResponseViewModel()
            {
                token = encodedToken,
                expiration = tokenExpirationMins,
                userName = username,
                userId = userId
            };
        }
    }
}
