
namespace Business_logic.Models
{
    public class Slot
    {
        public int fromHour { get; set; }
        public string dlvModeId { get; set; }
        public int slotId { get; set; }
        public bool isFlexDelivery { get; set; }
        public string text { get; set; }
        public bool isMealKitEligible { get; set; }
        public int amountMinor { get; set; }
        public int amount { get; set; }
        public string amountText { get; set; }
        public string mobileAmountText { get; set; }
        public bool soldOut { get; set; }
        public bool isDiscounted { get; set; }
        public bool isDeliverable { get; set; }
        public bool isAlternativeDeadline { get; set; }
    }
}
