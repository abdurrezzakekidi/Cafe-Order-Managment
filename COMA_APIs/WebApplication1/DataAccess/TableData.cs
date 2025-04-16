using Microsoft.Data.SqlClient;
using System.Data;

namespace WebApplication1.DataAccess
{
    public class TableData
    {
        public class TableDTO
        {
            public TableDTO(int id, int no, string status)
            {
                this.Id = id;
                this.No = no;
                this.Status = status;
            }


            public int Id { get; set; }
            public int No { get; set; }
            public string Status { get; set; }
        }

        public class TableOrdersDTO
        {
            public TableOrdersDTO(string name, decimal price)
            {
                this.Name = name;
                this.Price = price;
            }


            public string Name { get; set; }
            public decimal Price { get; set; }
        }

        public static List<TableDTO> GetAllTables()
        {
            var StudentsList = new List<TableDTO>();

            using (SqlConnection conn = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_GetAllTables", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                StudentsList.Add(new TableDTO
                                (
                                    reader.GetInt32(reader.GetOrdinal("Id")),
                                    reader.GetInt32(reader.GetOrdinal("No")),
                                    reader.GetString(reader.GetOrdinal("Status"))
                                ));
                            }
                        }
                    }
                    catch
                    {

                    }
                }
                return StudentsList;
            }
        }

        public static List<TableOrdersDTO> GetAllTableOrders(int tableId)
        {
            var StudentsList = new List<TableOrdersDTO>();

            using (SqlConnection conn = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_GetAllTableOrders", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("TableId", tableId);
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                StudentsList.Add(new TableOrdersDTO
                                (
                                    reader.GetString(reader.GetOrdinal("Name")),
                                    reader.GetDecimal(reader.GetOrdinal("Price"))
                                ));
                            }
                        }
                    }
                    catch
                    {

                    }
                }
                return StudentsList;
            }
        }
        public static TableDTO? GetTableById(int tableId)
        {
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_GetTableById", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@TableId", tableId);

                        connection.Open();
                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new TableDTO
                                (
                                    reader.GetInt32(reader.GetOrdinal("Id")),
                                    reader.GetInt32(reader.GetOrdinal("No")),
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
        public static int AddTable(TableDTO tableDTO)
        {
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_AddNewTable", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@No", tableDTO.No);
                        command.Parameters.AddWithValue("@Status", tableDTO.Status);
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
        public static bool UpdateTable(TableDTO tableDTO)
        {
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_UpdateTable", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@Id", tableDTO.Id);
                        command.Parameters.AddWithValue("@No", tableDTO.No);
                        command.Parameters.AddWithValue("@Status", tableDTO.Status);

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
        public static bool PayTableOrders(int tableId)
        {
            int rowsAffected = 0;
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_PayTableOrders", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@TableId", tableId);

                        connection.Open();

                        rowsAffected = command.ExecuteNonQuery();
                        return (rowsAffected != 0);
                    }
                    catch { }
                }
            }
            return false;
        }

        public static bool DeleteTable(int tableId)
        {
            int rowsAffected = 0;
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_DeleteTable", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;
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
    }
}
