using Microsoft.Data.SqlClient;
using System.Data;

namespace WebApplication1.DataAccess
{
    public class UserData
    {
        public class UserDTO
        {
            public UserDTO(int id, string name, string password, string role, string imagePath)
            {
                this.Id = id;
                this.Name = name;
                this.Password = password;
                this.Role = role;
                ImagePath = imagePath;
            }


            public int Id { get; set; }
            public string Name { get; set; }
            public string Password { get; set; }
            public string Role { get; set; }
            public string ImagePath { get; set; }
        }

        public static List<UserDTO> GetAllUsers()
        {
            var StudentsList = new List<UserDTO>();

            using (SqlConnection conn = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_GetAllUsers", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                StudentsList.Add(new UserDTO
                                (
                                    reader.GetInt32(reader.GetOrdinal("Id")),
                                    reader.GetString(reader.GetOrdinal("Name")),
                                    reader.GetString(reader.GetOrdinal("Password")),
                                    reader.GetString(reader.GetOrdinal("Role")),
                                    reader.IsDBNull(reader.GetOrdinal("imagePath")) ? string.Empty : reader.GetString(reader.GetOrdinal("imagePath"))
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
        public static UserDTO? GetUserById(int userId)
        {
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_GetUserById", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@UserId", userId);

                        connection.Open();
                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new UserDTO
                                (
                                    reader.GetInt32(reader.GetOrdinal("Id")),
                                    reader.GetString(reader.GetOrdinal("Name")),
                                    reader.GetString(reader.GetOrdinal("Password")),
                                    reader.GetString(reader.GetOrdinal("Role")),
                                    reader.IsDBNull(reader.GetOrdinal("imagePath")) ? string.Empty : reader.GetString(reader.GetOrdinal("imagePath"))
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
        public static UserDTO? Login(string username, string password)
        {
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_Login", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@Username", username);
                        command.Parameters.AddWithValue("@Password", password);

                        connection.Open();
                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new UserDTO
                                (
                                    reader.GetInt32(reader.GetOrdinal("Id")),
                                    reader.GetString(reader.GetOrdinal("Name")),
                                    reader.GetString(reader.GetOrdinal("Password")),
                                    reader.GetString(reader.GetOrdinal("Role")),
                                    reader.IsDBNull(reader.GetOrdinal("imagePath")) ? string.Empty : reader.GetString(reader.GetOrdinal("imagePath"))
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
        public static int AddUser(UserDTO userDTO)
        {
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_AddNewUser", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@Name", userDTO.Name);
                        command.Parameters.AddWithValue("@Password", userDTO.Password);
                        command.Parameters.AddWithValue("@Role", userDTO.Role);
                        var outputIdParam = new SqlParameter("@addedId", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(outputIdParam);

                        connection.Open();
                        command.ExecuteNonQuery();
                        var value = (int)command.Parameters["@addedId"].Value;
                        return value;
                    }
                    catch { }

                }
            }
            return -1;
        }
        public static bool UpdateUser(UserDTO userDTO)
        {
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_UpdateUser", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@Id", userDTO.Id);
                        command.Parameters.AddWithValue("@Name", userDTO.Name);
                        command.Parameters.AddWithValue("@Password", userDTO.Password);
                        command.Parameters.AddWithValue("@Role", userDTO.Role);

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
        public static bool DeleteUser(int userId)
        {
            int rowsAffected = 0;
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_DeleteUser", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@UserId", userId);

                        connection.Open();

                        rowsAffected = command.ExecuteNonQuery();
                        return (rowsAffected == 1);
                    }
                    catch { }
                }
            }
            return false;
        }

        public static bool UpdateUserImage(int id,string newPath)
        {
            using (var connection = new SqlConnection(clsDataAccessSettings.connectionString))
            {
                using (var command = new SqlCommand("SP_UpdateUserImage", connection))
                {
                    try
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@id", id);
                        command.Parameters.AddWithValue("@newPath", newPath);

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
    }
}
