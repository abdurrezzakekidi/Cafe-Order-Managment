using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using WebApplication1.Logic;
using static WebApplication1.DataAccess.TableData;

namespace WebApplication1.Controllers
{
    [Route("api/Tables")]
    [ApiController]
    public class TableAPIController : ControllerBase
    {
        [HttpGet("All", Name = "GetAllTables")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<IEnumerable<TableDTO>> GetAllTables()
        {
            List<TableDTO> TablesList = Table.GetAllTables();
            if (TablesList.Count == 0)
            {
                return NotFound("No Tables Found!");
            }
            return Ok(TablesList); // Returns the list of students.
        }


        [HttpGet("Orders/{tableId}", Name = "GetAllTableOrders")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<IEnumerable<TableOrdersDTO>> GetAllTableOrders(int tableId)
        {
            List<TableOrdersDTO> TablesList = Table.GetAllTableOrders(tableId);
            if (TablesList.Count == 0)
            {
                return NotFound("No Orders Found!");
            }
            return Ok(TablesList); // Returns the list of students.
        }


        [HttpPost("Pay/{tableId}", Name = "PayTableOrders")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult PayTableOrders(int tableId)
        {
            if (tableId < 1)
            {
                return BadRequest("Invalid Table data.");
            }

            if (Table.PayTableOrders(tableId))
                return Ok();

            return StatusCode(StatusCodes.Status500InternalServerError);

        }



        //[HttpGet("{id}", Name = "GetTableById")]
        //[ProducesResponseType(StatusCodes.Status200OK)]
        //[ProducesResponseType(StatusCodes.Status400BadRequest)]
        //[ProducesResponseType(StatusCodes.Status404NotFound)]
        //public ActionResult<TableDTO> GetTableById(int id)
        //{

        //    if (id < 1)
        //    {
        //        return BadRequest($"Not accepted ID {id}");
        //    }


        //    COMABusinessLayer.Table Table = COMABusinessLayer.Table.Find(id);

        //    if (Table == null)
        //    {
        //        return NotFound($"Table with ID {id} not found.");
        //    }

        //    //here we get only the DTO object to send it back.
        //    TableDTO TDTO = Table.TDTO;

        //    //we return the DTO not the student object.
        //    return Ok(TDTO);

        //}


        [HttpPost(Name = "AddTable")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public ActionResult<TableDTO> AddTable(TableDTO newTableDTO)
        {
            //we validate the data here
            if (newTableDTO == null || string.IsNullOrEmpty(newTableDTO.Status) || newTableDTO.No < 1)
            {
                return BadRequest("Invalid Table data.");
            }

            //newStudent.Id = StudentDataSimulation.StudentsList.Count > 0 ? StudentDataSimulation.StudentsList.Max(s => s.Id) + 1 : 1;

            Table Table = new Table(new TableDTO(newTableDTO.Id, newTableDTO.No, newTableDTO.Status));
            if (Table.Save())
                return Ok();
            else
                return NotFound();

        }

        [HttpPut("{id}", Name = "UpdateTable")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<TableDTO> UpdateTable(int id, TableDTO updatedTable)
        {
            if (id < 1 || updatedTable == null || string.IsNullOrEmpty(updatedTable.Status) || updatedTable.No < 1)
            {
                return BadRequest("Invalid Table data.");
            }

            //var student = StudentDataSimulation.StudentsList.FirstOrDefault(s => s.Id == id);

            Table? Table = Table.Find(id);


            if (Table == null)
            {
                return NotFound($"Table with ID {id} not found.");
            }


            Table.No = updatedTable.No;
            Table.Status = updatedTable.Status;
            Table.Save();

            //we return the DTO not the full student object.
            return Ok(Table.TDTO);

        }


        [HttpDelete("{id}", Name = "DeleteTable")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult DeleteTable(int id)
        {
            if (id < 1)
            {
                return BadRequest($"Not accepted ID {id}");
            }

            // var student = StudentDataSimulation.StudentsList.FirstOrDefault(s => s.Id == id);
            // StudentDataSimulation.StudentsList.Remove(student);

            if (Table.DeleteTable(id))

                return Ok($"Table with ID {id} has been deleted.");
            else
                return NotFound($"Table with ID {id} not found. no rows deleted!");
        }
    }
}
