using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;

namespace Business_logic
{
    public class ExcelReader
    {

        public List<string> ReadExcel(Stream file)
        {
            String sheetName = "Danish_Zips";
            String delimiter = ";";
            int startColumn = 1;// 2 convert to B 
            int endColumn = 1; // read until column 6
            int startRow = 2; // start read from row 31

            String columnRequest = "Request";
            DataTable dt = new DataTable();
            dt.Columns.Add(columnRequest);
            DataRow dr;
            String stringRequest = "";
            String stringNopek = "Init";
            String value = "";
            int indexRow = 0;
            using (SpreadsheetDocument myDoc = SpreadsheetDocument.Open(file, false))
            {
                WorkbookPart wbPart = myDoc.WorkbookPart;

                indexRow = startRow;
                while (!stringNopek.Equals(""))
                {
                    stringNopek = GetCellValue(GetExcelColumnName(startColumn) + indexRow.ToString(), sheetName, wbPart).Trim();
                    stringRequest = stringNopek;
                    if (!stringNopek.Equals(""))
                    {
                        dr = dt.NewRow();
                        for (int i = startColumn + 1; i <= endColumn; i++)
                        {
                            value = GetCellValue(GetExcelColumnName(i) + indexRow.ToString(), sheetName, wbPart).Trim();
                            stringRequest += delimiter + value;
                        }
                        dr[columnRequest] = stringRequest;
                        dt.Rows.Add(dr);
                    }
                    indexRow++;
                }
            }


            List<string> output = new List<string>();
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                output.Add( dt.Rows[i][columnRequest].ToString());
            }

            return output;
        }   

        private string GetExcelColumnName(int columnNumber)
        {
            int dividend = columnNumber;
            string columnName = String.Empty;
            int modulo;

            while (dividend > 0)
            {
                modulo = (dividend - 1) % 26;
                columnName = Convert.ToChar(65 + modulo).ToString() + columnName;
                dividend = (int)((dividend - modulo) / 26);
            }

            return columnName;
        }

        private int ColumnIndex(string reference)
        {
            int ci = 0;
            reference = reference.ToUpper();
            for (int ix = 0; ix < reference.Length && reference[ix] >= 'A'; ix++)
                ci = (ci * 26) + ((int)reference[ix] - 64);
            return ci;
        }

        private String GetCellValue(String cellReference, String sheetName, WorkbookPart wbPart)
        {
            Sheet theSheet = wbPart.Workbook.Descendants<Sheet>().
              Where(s => s.Name == sheetName).FirstOrDefault();
            if (theSheet == null)
            {
                throw new ArgumentException(sheetName);
            }
            WorksheetPart wsPart =
                (WorksheetPart)(wbPart.GetPartById(theSheet.Id));
            Cell theCell = wsPart.Worksheet.Descendants<Cell>().
              Where(c => c.CellReference == cellReference).FirstOrDefault();

            String value = "";

            if (theCell != null)
            {
                if (theCell.CellValue != null)
                {
                    value = theCell.CellValue.Text;
                }
                else
                {
                    value = value = theCell.InnerText;
                }
                if (theCell.DataType != null)
                {
                    switch (theCell.DataType.Value)
                    {
                        case CellValues.SharedString:

                            var stringTable =
                                wbPart.GetPartsOfType<SharedStringTablePart>()
                                .FirstOrDefault();
                            if (stringTable != null)
                            {
                                value =
                                    stringTable.SharedStringTable
                                    .ElementAt(int.Parse(value)).InnerText;
                            }
                            break;

                        case CellValues.Boolean:
                            switch (value)
                            {
                                case "0":
                                    value = "FALSE";
                                    break;
                                default:
                                    value = "TRUE";
                                    break;
                            }
                            break;
                    }
                }
            }

            return value;
        }

    }
}
