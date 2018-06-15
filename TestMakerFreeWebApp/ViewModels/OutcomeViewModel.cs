using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TestMakerFreeWebApp.ViewModels
{
    [JsonObject(MemberSerialization.OptOut)]
    public class OutcomeViewModel
    {
        public OutcomeViewModel() {}

        public int Id { get; set; }
        public int QuizId { get; set; }
        public string UserName { get; set; }
        public string ResultDesc { get; set; }
    }
}
