using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace TestMakerFreeWebApp.Data
{
    public class Outcome
    {

        public Outcome() { }

        #region Properties
        [Key]
        [Required]
        public int Id { get; set; }
        [Required]
        public int QuizId { get; set; }
        [Required]
        public string UserName { get; set; }
        [Required]
        public string ResultDesc { get; set; }

        [Required]
        public DateTime CreatedDate { get; set; }
        [Required]
        public DateTime LastModifiedDate { get; set; }

        #endregion

        #region Lazy-Load Properties
        /// <summary>
        /// The parent quiz.
        /// </summary>
        [ForeignKey("QuizId")]
        public virtual Quiz Quiz { get; set; }
        #endregion
    }
}
