﻿using System;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using TestMakerFreeWebApp.ViewModels;
using System.Collections.Generic;
using System.Linq;
using TestMakerFreeWebApp.Data;
using Mapster;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace TestMakerFreeWebApp.Controllers
{
    public class QuizController : BaseApiController
    {
        #region Constructor
        public QuizController(
            ApplicationDbContext context,
            RoleManager<IdentityRole> roleManager,
            UserManager<ApplicationUser> userManager,
            IConfiguration configuration
            )
            : base(context, roleManager, userManager, configuration) { }
        #endregion

        #region RESTful conventions methods
        /// <summary>
        /// GET: api/quiz/{id}
        /// Retrieves the Quiz with the given {id}
        /// </summary>
        /// <param name="id">The ID of an existing Quiz</param>
        /// <returns>the Quiz with the given {id}</returns>
        [HttpGet("{id}")]
        public async Task<IActionResult> Get(int id)
        {
            var quiz = await DbContext.Quizzes.Where(i => i.Id == id).FirstOrDefaultAsync();

            //handle requests asking for non-exisiting quizzes
            if (quiz == null)
            {
                return NotFound(new
                {
                    Error = String.Format("Quiz ID {0} has not been found", id)
                });
            }

            // output the result in JSON format
            return new JsonResult(
                quiz.Adapt<QuizViewModel>(),
                new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
        }

        /// <summary>
        /// Adds a new Quiz to the Database
        /// </summary>
        /// <param name="model">The QuizViewModel containing the data to insert</param>
        [HttpPut]
        [Authorize]
        public IActionResult Put([FromBody] QuizViewModel model)
        {
            // throw new NotImplementedException();
            // return a generic HTTP Status 500 (Server Error)
            // if the client payload is invalid.
            if (model == null) return new StatusCodeResult(500);

            // handle the insert (without object-mapping)
            var quiz = new Quiz();

            //properties taken for the request
            quiz.Title = model.Title;
            quiz.Description = model.Description;
            quiz.Text = model.Text;
            quiz.Notes = model.Notes;

            //properties set from server-side
            quiz.CreatedDate = DateTime.Now;
            quiz.LastModifiedDate = quiz.CreatedDate;

            // retrieve the current user's Id
            quiz.UserId = User.FindFirst(ClaimTypes.NameIdentifier).Value;

            // add the new quiz
            DbContext.Quizzes.Add(quiz);
            // persist the changes into the Database
            DbContext.SaveChanges();

            // return the newly-created Quiz to the client
            return new JsonResult(quiz.Adapt<QuizViewModel>(),
                    new JsonSerializerSettings()
                    {
                        Formatting = Formatting.Indented
                    });
        }

        /// <summary>
        /// Edit the Quiz sent in via the model
        /// </summary>
        /// <param name="model">The QuizViewModel containing the data to update</param>
        [HttpPost]
        [Authorize]
        public IActionResult Post([FromBody]QuizViewModel model)
        {
            // return a generic HTTP Status 500 (Server Error)
            // if the client payload is invalid.
            if (model == null) return new StatusCodeResult(500);

            // retrieve the quiz to edit
            var quiz = DbContext.Quizzes.Where(q => q.Id ==
                        model.Id).FirstOrDefault();

            // handle requests asking for non-existing quizzes
            if (quiz == null)
            {
                return NotFound(new
                {
                    Error = String.Format("Quiz ID {0} has not been found", model.Id)
                });
            }

            // handle the update (without object-mapping)
            //   by manually assigning the properties 
            //   we want to accept from the request
            quiz.Title = model.Title;
            quiz.Description = model.Description;
            quiz.Text = model.Text;
            quiz.Notes = model.Notes;

            // properties set from server-side
            quiz.LastModifiedDate = quiz.CreatedDate;

            // persist the changes into the Database.
            DbContext.SaveChanges();

            // return the updated Quiz to the client.
            return new JsonResult(quiz.Adapt<QuizViewModel>(),
                new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
        }

        /// <summary>
        /// Deletes the Quiz with the given {id} from the Database
        /// </summary>
        /// <param name="id">The ID of an existing Test</param>
        [HttpDelete("{id}")]
        [Authorize]
        public IActionResult Delete(int id)
        {
            // retrieve the quiz from the Database
            var quiz = DbContext.Quizzes.Where(i => i.Id == id)
                .FirstOrDefault();

            // handle requests asking for non-existing quizzes
            if (quiz == null)
            {
                return NotFound(new
                {
                    Error = String.Format("Quiz ID {0} has not been found", id)
                });
            }

            // remove the quiz from the DbContext.
            DbContext.Quizzes.Remove(quiz);
            // persist the changes into the Database.
            DbContext.SaveChanges();

            // return an HTTP Status 200 (OK).
            // return new OkResult();

            return new NoContentResult();
        }
        #endregion

        #region Attribute-based routing methods
        /// <summary>
        /// GET: api/quiz/latest
        /// Retrieves the {num} latest Quizzes
        /// </summary>
        /// <param name="num">the number of quizzes to retrieve</param>
        /// <returns>the {num} latest Quizzes</returns>
        [HttpGet("Latest/{num:int?}")]
        public IActionResult Latest(int num = 10)
        {
            var latest = DbContext.Quizzes.OrderByDescending(q => q.CreatedDate).Take(num).ToArray();

            // output the result in JSON format
            return new JsonResult(
                latest.Adapt<QuizViewModel[]>(),
                new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
        }

        /// <summary>
        /// GET: api/quiz/ByTitle
        /// Retrieves the {num} Quizzes sorted by Title (A to Z)
        /// </summary>
        /// <param name="num">the number of quizzes to retrieve</param>
        /// <returns>{num} Quizzes sorted by Title</returns>
        [HttpGet("ByTitle/{num:int?}")]
        public IActionResult ByTitle(int num = 10)
        {
            var byTitle = DbContext.Quizzes.OrderBy(q => q.Title).Take(num).ToArray();

            return new JsonResult(
                byTitle.Adapt<QuizViewModel[]>(),
                new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
        }

        /// <summary>
        /// GET: api/quiz/Random
        /// Retrieves the {num} random Quizzes
        /// </summary>
        /// <param name="num">the number of quizzes to retrieve</param>
        /// <returns>{num} random Quizzes</returns>
        [HttpGet("Random/{num:int?}")]
        public IActionResult Random(int num = 10)
        {
            var random = DbContext.Quizzes.OrderBy(q => Guid.NewGuid()).Take(num).ToArray();

            return new JsonResult(
                random.Adapt<QuizViewModel[]>(),
                new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
        }
        #endregion
    }
}