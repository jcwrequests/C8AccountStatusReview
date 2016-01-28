using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace C8AccountStatusReview.MidYear.Models
{
    public class AccountsModel
    {
        public Guid AccountId { get; set; }
        public string AccountName { get; set; }

        public List<Models.SchoolsModel> Schools { get; set; }
    }
}
