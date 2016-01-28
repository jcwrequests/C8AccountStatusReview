using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace C8AccountStatusReview.MidYear.Models
{
    public class CognitiveReportsUnlockedModel
    {
        public Guid SchoolId { get; set; }
        public string Category { get; set; }
        public int ReportCount { get; set; }

        public int CategoryOrder { get; set; }
    }
}
