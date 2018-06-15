using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Mapster;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using TestMakerFreeWebApp.Data;
using TestMakerFreeWebApp.ViewModels;

namespace TestMakerFreeWebApp.Controllers
{
    public class OutcomeController : BaseApiController
    {
        #region Constructor
        public OutcomeController(
            ApplicationDbContext context, 
            RoleManager<IdentityRole> roleManager, 
            UserManager<ApplicationUser> userManager, 
            IConfiguration configuration) 
            : base(context, roleManager, userManager, configuration)
        {
        }
        #endregion


        /// <summary>
        /// Create or Edit the Outcome sent in via the model
        /// </summary>
        /// <param name="model">The OutcomeViewModel containing the data to update</param>
        [HttpPost]
        [Authorize]
        public IActionResult Post([FromBody]OutcomeViewModel model)
        {
            // return a generic HTTP Status 500 (Server Error)
            // if the client payload is invalid.
            if (model == null) return new StatusCodeResult(500);

            // retrieve the outcome to edit
            var outcome = DbContext.Outcomes.Where(o => o.UserName ==
                        model.UserName && o.QuizId == model.QuizId).FirstOrDefault();

            // if the outcome is null, create a new outcome
            if (outcome == null)
            {
                outcome = new Outcome();
                outcome.QuizId = model.QuizId;
                outcome.UserName = model.UserName;
                outcome.ResultDesc = model.ResultDesc;
                outcome.CreatedDate = DateTime.Now;
                outcome.LastModifiedDate = DateTime.Now;
                DbContext.Outcomes.Add(outcome);
                // persist the changes into the Database.
                DbContext.SaveChanges();
            } else {
                // The outcome is not null, so we edit it
                outcome.QuizId = model.QuizId;
                outcome.UserName = model.UserName;
                outcome.ResultDesc = model.ResultDesc;
                outcome.LastModifiedDate = DateTime.Now;
                // persist the changes into the Database.
                DbContext.SaveChanges();
            };


            // return the updated outcome to the client.
            return new JsonResult(
                outcome.Adapt<OutcomeViewModel>(),
                new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
        }

        // GET api/outcome/All
        [HttpGet("All/{id}")]
        public IActionResult All(int id)
        {
            var outcomes = DbContext.Outcomes.Where(o => o.QuizId == id).ToArray();

            // output the result in JSON format
            return new JsonResult(
                outcomes.Adapt<OutcomeViewModel[]>(),
                new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
        }

        // GET api/outcome/ByUser
        [HttpGet("ByUser/{userName}")]
        public IActionResult ByUser(string name)
        {
            var outcomes = DbContext.Outcomes.Where(o => o.UserName == name).ToArray();

            // output the result in JSON format
            return new JsonResult(
                outcomes.Adapt<OutcomeViewModel[]>(),
                new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
        }
    }
}
