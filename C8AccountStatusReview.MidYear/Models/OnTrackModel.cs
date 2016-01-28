using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace C8AccountStatusReview.MidYear.Models
{
    public class OnTrackModel
    {
        public Guid SchoolId { get; set; }
        public string Category { get; set; }
        public decimal Percentage { get; set; }
    }
}
