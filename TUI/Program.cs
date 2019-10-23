using Business_logic;
using Business_logic.Models;
using System;
using System.Collections.Generic;

namespace TUI
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                StartProgram();
                Console.Beep();
            }
            catch(Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }

        private static void StartProgram()
        {

            List<List<DeliveryDays>> allZipDeliveries = new List<List<DeliveryDays>>();
            List<string> zipCodes;
            Scraper scraper = new Scraper();
            DbControl dbControl = new DbControl();

            Console.WriteLine("Reading zip codes");

            ExcelReader e = new ExcelReader();
            zipCodes = scraper.GetZipCodes();

            Console.WriteLine("Getting data for each zip code");

            for (int i = 0; i < zipCodes.Count - 1; i++)
            {
                DrawTextProgressBar(i, zipCodes.Count);
                var deliveries = scraper.GetCleanData(zipCodes[i]); // possible to send month and year as well
                if (deliveries != null)
                {
                    allZipDeliveries.Add(deliveries);
                    foreach (DeliveryDays d in deliveries)
                    {
                        string deliveryId = dbControl.InsertDelivery(d, zipCodes[i]);
                        foreach (Slot s in d.slots)
                        {
                            dbControl.InsertSlot(s, deliveryId);
                        }
                    }
                }
                else
                {
                    dbControl.InsertNotSupported(zipCodes[i]);
                    Console.WriteLine(zipCodes[i] + "NOT SUPPORTED");
                }
            }

            Console.WriteLine("done");
        }

        private static void DrawTextProgressBar(int progress, int total)
        {
            //draw empty progress bar
            Console.CursorLeft = 0;
            Console.Write("["); //start
            Console.CursorLeft = 32;
            Console.Write("]"); //end
            Console.CursorLeft = 1;
            float onechunk = 30.0f / total;

            //draw filled part
            int position = 1;
            for (int i = 0; i < onechunk * progress; i++)
            {
                Console.BackgroundColor = ConsoleColor.Gray;
                Console.CursorLeft = position++;
                Console.Write(" ");
            }

            //draw unfilled part
            for (int i = position; i <= 31; i++)
            {
                Console.BackgroundColor = ConsoleColor.Green;
                Console.CursorLeft = position++;
                Console.Write(" ");
            }

            //draw totals
            Console.CursorLeft = 35;
            Console.BackgroundColor = ConsoleColor.Black;
            Console.Write(progress.ToString() + " of " + total.ToString() + "    "); //blanks at the end remove any excess
        }
    }
}
