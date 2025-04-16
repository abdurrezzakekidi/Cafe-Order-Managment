using Microsoft.Data.SqlClient;
using System.Data;

namespace WebApplication1.DataAccess
{
    public class ProductData
    {
        public class ProductDTO
        {
            public ProductDTO(int id, string name, decimal price, string status)
            {
                this.Id = id;
                this.Name = name;
                this.Price = price;
                this.Status = status;
            }


            public int Id { get; set; }
            public string Name { get; set; }
            public decimal Price { get; set; }
            public string Status { get; set; }
        }
        public static List<ProductDTO> GetAllProducts()
        {
            var StudentsList = new List<ProductDTO>();

            using (SqlConnection conn = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_GetAllProducts", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                StudentsList.Add(new ProductDTO
                                (
                                    reader.GetInt32(reader.GetOrdinal("Id")),
                                    reader.GetString(reader.GetOrdinal("Name")),
                                    reader.GetDecimal(reader.GetOrdinal("Price")),
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


        public static ProductDTO? GetProductById(int ProductId)
        {
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_GetProductById", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@ProductId", ProductId);

                        connection.Open();
                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new ProductDTO
                                (
                                    reader.GetInt32(reader.GetOrdinal("Id")),
                                    reader.GetString(reader.GetOrdinal("Name")),
                                    reader.GetDecimal(reader.GetOrdinal("Price")),
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

        public static int AddProduct(ProductDTO ProductDTO)
        {
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_AddNewProduct", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@Name", ProductDTO.Name);
                        command.Parameters.AddWithValue("@Price", ProductDTO.Price);
                        command.Parameters.AddWithValue("@Status", ProductDTO.Status);

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

        public static bool UpdateProduct(ProductDTO ProductDTO)
        {
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_UpdateProduct", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@Id", ProductDTO.Id);
                        command.Parameters.AddWithValue("@Name", ProductDTO.Name);
                        command.Parameters.AddWithValue("@Price", ProductDTO.Price);
                        command.Parameters.AddWithValue("@Status", ProductDTO.Status);

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

        public static bool DeleteProduct(int ProductId)
        {
            int rowsAffected = 0;
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_DeleteProduct", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@ProductId", ProductId);

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
