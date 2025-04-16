using WebApplication1.DataAccess;
using static WebApplication1.DataAccess.UserData;

namespace WebApplication1.Logic
{
    public class User
    {
        public enum enMode { AddNew = 0, Update = 1 };
        public enMode Mode = enMode.AddNew;

        public UserDTO UDTO
        {
            get
            {
                return (new UserDTO(this.ID, this.Name, this.Password, this.Role,this.ImagePath));
            }
        }
        public int ID { get; set; }
        public string Name { get; set; }
        public string Password { get; set; }
        public string Role { get; set; }
        public string ImagePath { get; set; }


        public User(UserDTO UDTO, enMode cMode = enMode.AddNew)
        {
            this.ID = UDTO.Id;
            this.Name = UDTO.Name;
            this.Password = UDTO.Password;
            this.Role = UDTO.Role;
            this.ImagePath = UDTO.ImagePath;

            Mode = cMode;
        }

        private bool _AddNewUser()
        {
            //call DataAccess Layer 

            this.ID = UserData.AddUser(UDTO);

            return (this.ID != -1);
        }

        private bool _UpdateUser()
        {
            return UserData.UpdateUser(UDTO);
        }
        public static List<UserDTO> GetAllUsers()
        {
            return UserData.GetAllUsers();
        }

        public static User? Find(int ID)
        {

            var UDTO = UserData.GetUserById(ID);

            if (UDTO != null)
            //we return new object of that student with the right data
            {

                return new User(UDTO, enMode.Update);
            }
            else
                return null;
        }
        public static User? Login(string username, string password)
        {

            var UDTO = UserData.Login(username, password);

            if (UDTO != null)
            //we return new object of that student with the right data
            {

                return new User(UDTO, enMode.Update);
            }
            else
                return null;
        }

        public bool Save()
        {
            switch (Mode)
            {
                case enMode.AddNew:
                    if (_AddNewUser())
                    {

                        Mode = enMode.Update;
                        return true;
                    }
                    else
                    {
                        return false;
                    }

                case enMode.Update:

                    return _UpdateUser();

            }

            return false;
        }

        public static bool DeleteUser(int ID)
        {
            return UserData.DeleteUser(ID);
        }

        public static bool UpdateUserImage(int id,string newPath)
        {
            return UserData.UpdateUserImage(id,newPath);
        }
    }
}
