using Business_logic.Models;
using System;
using System.Data;
using System.Data.SqlClient;
namespace Business_logic
{
    public class DbControl
    {
        string connectionString = @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=Deliveries;Integrated Security=True;Connect Timeout=30;Encrypt=False;TrustServerCertificate=False;ApplicationIntent=ReadWrite;MultiSubnetFailover=False";
        public string InsertSlot(Slot slot, string deliveryId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // 1.  create a command object identifying the stored procedure
                SqlCommand cmd = new SqlCommand("AddSlots", conn);

                // 2. set the command object so it knows to execute a stored procedure
                cmd.CommandType = CommandType.StoredProcedure;

                // 3. add parameter to command, which will be passed to the stored procedure
                cmd.Parameters.Add(new SqlParameter("@deliveryId", deliveryId));
                cmd.Parameters.Add(new SqlParameter("@fromHour", slot.fromHour));
                cmd.Parameters.Add(new SqlParameter("@dlvModeId", slot.dlvModeId));
                cmd.Parameters.Add(new SqlParameter("@isFlexDelivery", slot.isFlexDelivery));
                cmd.Parameters.Add(new SqlParameter("@text", slot.text));
                cmd.Parameters.Add(new SqlParameter("@isMealKitEligible", slot.isMealKitEligible));
                cmd.Parameters.Add(new SqlParameter("@amountMinor", slot.amountMinor));
                cmd.Parameters.Add(new SqlParameter("@amount", slot.amount));
                cmd.Parameters.Add(new SqlParameter("@amountText", slot.amountText));
                cmd.Parameters.Add(new SqlParameter("@mobileAmountText", slot.mobileAmountText));
                cmd.Parameters.Add(new SqlParameter("@soldOut", slot.soldOut));
                cmd.Parameters.Add(new SqlParameter("@isDiscounted", slot.isDiscounted));
                cmd.Parameters.Add(new SqlParameter("@isDeliverable", slot.isDeliverable));
                cmd.Parameters.Add(new SqlParameter("@isAlternativeDeadline", slot.isAlternativeDeadline));

                // execute the command
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    // iterate through results, printing each to console
                    while (rdr.Read())
                    {
                        return rdr["slotId"].ToString();
                    }
                }
                return "";
            }
        }

        public void InsertNotSupported(string v)
        {

        }

        public string InsertDelivery(DeliveryDays delivery, string zipCode)
        {

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // 1.  create a command object identifying the stored procedure
                SqlCommand cmd = new SqlCommand("AddDelivery", conn);

                // 2. set the command object so it knows to execute a stored procedure
                cmd.CommandType = CommandType.StoredProcedure;

                // 3. add parameter to command, which will be passed to the stored procedure
                cmd.Parameters.Add(new SqlParameter("@zipCode", zipCode));
                cmd.Parameters.Add(new SqlParameter("@mobileText", delivery.mobileText));
                cmd.Parameters.Add(new SqlParameter("@date", delivery.date));
                cmd.Parameters.Add(new SqlParameter("@text", delivery.text));
                cmd.Parameters.Add(new SqlParameter("@active", delivery.active));
                cmd.Parameters.Add(new SqlParameter("@inMonth", delivery.inMonth));
                cmd.Parameters.Add(new SqlParameter("@cheapestAmount", delivery.cheapestAmount));

                // execute the command
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    // iterate through results, printing each to console
                    while (rdr.Read())
                    {
                        return rdr["deliveryId"].ToString();
                    }
                }
                return "";
            }
        }
    }
}
