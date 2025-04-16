using Microsoft.Data.SqlClient;
using System.Data;

namespace WebApplication1.DataAccess
{
    public class OrderDTO
    {
        public OrderDTO(int id, int tableId, int productId, string status)
        {
            this.Id = id;
            this.TableId = tableId;
            this.ProductId = productId;
            this.Status = status;
        }


        public int Id { get; set; }
        public int TableId { get; set; }
        public int ProductId { get; set; }
        public string Status { get; set; }
    }
    public class OrdersDTO
    {
        public OrdersDTO(int no, string status, string name, int id)
        {
            this.No = no;
            this.Status = status;
            this.Name = name;
            this.id = id;
        }
        public int No { get; set; }
        public string Name { get; set; }
        public int id { get; set; }
        public string Status { get; set; }

    }

    public class ReportDTO
    {
        public string ProductName { get; set; }
        public int Quantity { get; set; }

        public decimal TotalAmount { get; set; }
        public ReportDTO(string productName, int quantity, decimal TotalAmount)
        {
            this.ProductName = productName;
            this.Quantity = quantity;
            this.TotalAmount = TotalAmount;
        }
    }

    public class MonthlyReportDTO
    {
        public DateTime Day { get; set; }
        public decimal DailyRevenue { get; set; }
        public MonthlyReportDTO(DateTime Day, decimal DailyRevenue)
        {
            this.Day = Day;
            this.DailyRevenue = DailyRevenue;
        }
    }
    public class YearlyMonthlyReportDTO
    {
        public string MonthName { get; set; }
        public int MonthNumber { get; set; }
        public decimal MonthlyRevenue { get; set; }
        public YearlyMonthlyReportDTO(string monthName, int monthNum, decimal monthlyRevenue)
        {
            this.MonthName = monthName;
            this.MonthNumber = monthNum;
            this.MonthlyRevenue = monthlyRevenue;
        }
    }
    public class OrderData
    {
        public static List<OrdersDTO> GetAllOrders()
        {
            var OrdersList = new List<OrdersDTO>();

            using (SqlConnection conn = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_GetAllOrders", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                OrdersList.Add(new OrdersDTO
                                (
                                    reader.GetInt32(reader.GetOrdinal("No")),
                                    reader.GetString(reader.GetOrdinal("Status")),
                                    reader.GetString(reader.GetOrdinal("Name")),
                                    reader.GetInt32(reader.GetOrdinal("id"))

                                ));
                            }
                        }
                    }
                    catch
                    {

                    }
                }
                return OrdersList;
            }
        }

        public static List<OrderDTO> GetTableOrders(int id) // masa id
        {
            var OrdersList = new List<OrderDTO>();

            using (SqlConnection conn = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_GetTableOrders", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@TableId", id);
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                OrdersList.Add(new OrderDTO
                                (
                                    reader.GetInt32(reader.GetOrdinal("id")),
                                    reader.GetInt32(reader.GetOrdinal("TableId")),
                                    reader.GetInt32(reader.GetOrdinal("ProductId")),
                                    reader.GetString(reader.GetOrdinal("Status"))
                                ));
                            }
                        }
                    }
                    catch
                    {

                    }
                }
                return OrdersList;
            }
        }
        public static OrderDTO? GetOrderById(int OrderId)
        {
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_GetOrderById", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@OrderId", OrderId);

                        connection.Open();
                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new OrderDTO
                                (
                                    reader.GetInt32(reader.GetOrdinal("id")),
                                    reader.GetInt32(reader.GetOrdinal("TableId")),
                                    reader.GetInt32(reader.GetOrdinal("ProductId")),
                                    reader.GetString(reader.GetOrdinal("Status"))
                                );
                            }
                            else
                            {
                                return null;
                            }
                        }
                    }
                    catch
                    {

                    }
                }
            }
            return null;
        }
        public static int AddOrder(OrderDTO OrderDTO)
        {
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_AddNewOrder", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure; // primary key

                        command.Parameters.AddWithValue("@TableId", OrderDTO.TableId);
                        command.Parameters.AddWithValue("@ProductId", OrderDTO.ProductId);
                        command.Parameters.AddWithValue("@Status", OrderDTO.Status);
                        var outputIdParam = new SqlParameter("@addedId", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(outputIdParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        return (int)command.Parameters["@addedId"].Value;
                    }
                    catch { }

                }
            }
            return -1;
        }
        public static bool UpdateOrder(OrderDTO OrderDTO)
        {
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_UpdateOrder", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@Id", OrderDTO.Id);
                        command.Parameters.AddWithValue("@TableId", OrderDTO.TableId);
                        command.Parameters.AddWithValue("@ProductId", OrderDTO.ProductId);
                        command.Parameters.AddWithValue("@Status", OrderDTO.Status);

                        connection.Open();
                        command.ExecuteNonQuery();
                        return true;
                    }
                    catch
                    {
                        return false;
                    }

                }
            }
        }
        public static bool DeleteOrder(int OrderId, int tableId)
        {
            int rowsAffected = 0;
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_DeleteOrder", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure; // masa bos mu dolu mu
                        command.Parameters.AddWithValue("@OrderId", OrderId);
                        command.Parameters.AddWithValue("@TableId", tableId);

                        connection.Open();

                        rowsAffected = command.ExecuteNonQuery();
                        return (rowsAffected == 1);
                    }
                    catch { }
                }
            }
            return false;
        }

        public static List<ReportDTO> GetTodayReport()
        {
            List<ReportDTO> report = new List<ReportDTO>();

            using (SqlConnection conn = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_GetDailyReport", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                report.Add(new ReportDTO
                                (
                                    reader.GetString(reader.GetOrdinal("Name")),
                                    reader.GetInt32(reader.GetOrdinal("Quantity")),
                                    reader.GetDecimal(reader.GetOrdinal("TotalAmount"))
                                ));
                            }
                        }
                    }
                    catch
                    {

                    }
                }
                return report;
            }
        }


        public static List<MonthlyReportDTO> GetMonthlyReport()
        {
            List<MonthlyReportDTO> report = new List<MonthlyReportDTO>();

            using (SqlConnection conn = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_GetMonthlyDailyRevenue", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                report.Add(new MonthlyReportDTO
                                (
                                    reader.GetDateTime(reader.GetOrdinal("Day")),
                                    reader.GetDecimal(reader.GetOrdinal("DailyRevenue")) // 
                                ));
                            }
                        }
                    }
                    catch
                    {

                    }
                }
                return report;
            }
        }

        public static List<YearlyMonthlyReportDTO> GetYearlyMonthlyRevenue()
        {
            List<YearlyMonthlyReportDTO> report = new List<YearlyMonthlyReportDTO>();

            using (SqlConnection conn = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_GetYearlyMonthlyRevenue", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                report.Add(new YearlyMonthlyReportDTO
                                (
                                    reader.GetString(reader.GetOrdinal("MonthName")),
                                    reader.GetInt32(reader.GetOrdinal("MonthNumber")),
                                    reader.GetDecimal(reader.GetOrdinal("MonthlyRevenue"))
                                ));
                            }
                        }
                    }
                    catch
                    {

                    }
                }
                return report;
            }
        }
    }
}
