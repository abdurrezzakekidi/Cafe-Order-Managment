using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using static WebApplication1.Logic.User;
using static WebApplication1.DataAccess.UserData;
using Microsoft.Data.SqlClient;
using WebApplication1.DataAccess;
using WebApplication1.Global;
using WebApplication1.Models;

namespace WebApplication1.Controllers
{
    [Route("api/Users")]
    [ApiController]
    public class UserAPIController : ControllerBase
    {
        [HttpGet("{username}/{password}", Name = "Login")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<UserDTO> Login(string username, string password)
        {

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                return BadRequest($"Invalid username or password");
            }


            Logic.User? user = Logic.User.Login(username, password);

            if (user == null)
            {
                return NotFound($"User not found.");
            }

            //here we get only the DTO object to send it back.
            UserDTO UDTO = user.UDTO;

            //we return the DTO not the student object.
            return Ok(UDTO);

        }

        [HttpGet("All", Name = "GetAllUsers")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<IEnumerable<UserDTO>> GetAllUsers()
        {
            try
            {
                List<UserDTO> UsersList = Logic.User.GetAllUsers();
                if (UsersList.Count == 0)
                {
                    return NotFound("No Users Found!");
                }
                return Ok(UsersList); // Returns the list of students.
            }
            catch (Exception ex) 
            {
                return StatusCode(500,ex.Message);
            }

        }

        


        [HttpPost(Name = "AddUser")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public ActionResult<UserDTO> AddUser(UserDTO newUserDTO)
        {
            //we validate the data here
            if (newUserDTO == null || string.IsNullOrEmpty(newUserDTO.Name) || string.IsNullOrEmpty(newUserDTO.Password) || string.IsNullOrEmpty(newUserDTO.Role))
            {
                return BadRequest("Invalid user data.");
            }

            //newStudent.Id = StudentDataSimulation.StudentsList.Count > 0 ? StudentDataSimulation.StudentsList.Max(s => s.Id) + 1 : 1;

            Logic.User user = new Logic.User(new UserDTO(newUserDTO.Id, newUserDTO.Name, newUserDTO.Password, newUserDTO.Role,null));
            if (user.Save())
                return Ok();
            else
                return NotFound();

        }

        [HttpPut("{id}", Name = "UpdateUser")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<UserDTO> UpdateStudent(int id, UserDTO updatedUser)
        {
            if (id < 1 || updatedUser == null || string.IsNullOrEmpty(updatedUser.Name) || string.IsNullOrEmpty(updatedUser.Password) || string.IsNullOrEmpty(updatedUser.Role))
            {
                return BadRequest("Invalid user data.");
            }

            //var student = StudentDataSimulation.StudentsList.FirstOrDefault(s => s.Id == id);

            Logic.User? user = Logic.User.Find(id);


            if (user == null)
            {
                return NotFound($"User with ID {id} not found.");
            }


            user.Name = updatedUser.Name;
            user.Password = updatedUser.Password;
            user.Role = updatedUser.Role;
            user.Save();

            //we return the DTO not the full student object.
            return Ok(user.UDTO);

        }


        [HttpDelete("{id}", Name = "DeleteUser")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult DeleteUser(int id)
        {
            if (id < 1)
            {
                return BadRequest($"Not accepted ID {id}");
            }

            if (Logic.User.DeleteUser(id))

                return Ok($"User with ID {id} has been deleted.");
            else
                return NotFound($"User with ID {id} not found. no rows deleted!");
        }




        [HttpPut("UpdateImage", Name = "UpdateUserImage")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult> UpdateUserImage([FromForm] UpdateImageDTO info)
        {
            if (info.NewImage == null || string.IsNullOrEmpty(info.OldImagePath))
            {
                return BadRequest("Invalid image data.");
            }

            
            string newPath = await CloudinaryService.ReplaceImageAsync(info.NewImage, info.OldImagePath.Trim());

            if (Logic.User.UpdateUserImage(info.Id, newPath))
                return Ok(new { ImageName = newPath });
            else
                return StatusCode(500);
        }



       

    }
}
