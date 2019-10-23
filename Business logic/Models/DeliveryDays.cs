using System;
using System.Collections.Generic;

namespace Business_logic.Models
{
    public class DeliveryDays
    {
        public string? zipCode { get; set; }
        public int index { get; set; }
        public string? mobileText { get; set; }
        public DateTime? date { get; set; }
        public string? text { get; set; }
        public bool active { get; set; }
        public bool inMonth { get; set; }
        public List<Slot>? slots { get; set; }
        public int? cheapestAmount { get; set; }
    }
}
