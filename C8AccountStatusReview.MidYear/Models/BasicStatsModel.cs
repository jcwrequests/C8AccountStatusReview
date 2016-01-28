using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace C8AccountStatusReview.MidYear.Models
{
    public class BasicStatsModel
    {
        public Guid SchoolId { get; set; }
        public int Cohorts { get; set; }
        public int ActiveStudents { get; set; }
        public DateTime LastLogingDate { get; set; }
        public int TotalMinutesPlayed { get; set; }
    }
}
