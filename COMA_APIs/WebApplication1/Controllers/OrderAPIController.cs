using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using WebApplication1.DataAccess;
using WebApplication1.Logic;
using static WebApplication1.DataAccess.OrderData;

namespace WebApplication1.Controllers
{
    [Route("api/Orders")]
    [ApiController]
    public class OrderAPIController : ControllerBase
    {
        [HttpGet("All", Name = "GetAllOrders")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<IEnumerable<OrdersDTO>> GetAllOrders()
        {
            List<OrdersDTO> OrdersList = Order.GetAllOrders();
            if (OrdersList.Count == 0)
            {
                return NotFound("No Orders Found!");
            }
            return Ok(OrdersList); // Returns the list of students.

        }

        [HttpGet("Table/{id}", Name = "GetTableOrders")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<IEnumerable<OrderDTO>> GetTableOrders(int id)
        {
            List<OrderDTO> ProductsList = Order.GetTableOrders(id);
            if (ProductsList.Count == 0)
            {
                return NotFound("No Orders Found!");
            }
            return Ok(ProductsList); // Returns the list of students.
        }

        [HttpPost(Name = "AddOrder")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public ActionResult<OrderDTO> AddOrder(OrderDTO newOrderDTO)
        {
            if (newOrderDTO == null || newOrderDTO.TableId < 1 || newOrderDTO.ProductId < 1 || string.IsNullOrEmpty(newOrderDTO.Status))
            {
                return BadRequest("Invalid Order data.");
            }

            Order Order = new Order(new OrderDTO(newOrderDTO.Id, newOrderDTO.TableId, newOrderDTO.ProductId, newOrderDTO.Status));
            if(Order.Save())
            {
                return Ok(new {id = Order.Id, tableId = Order.TableId, productId = Order.ProductId, status = Order.Status});
            }
            else
            {
                return NotFound();
            }

        }


        [HttpDelete("{id}/{TableId}", Name = "DeleteOrder")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult DeleteOrder(int id, int tableId)
        {
            if (id < 1 || tableId < 1)
            {
                return BadRequest($"Not accepted ID {id}");
            }

            // var student = StudentDataSimulation.StudentsList.FirstOrDefault(s => s.Id == id);
            // StudentDataSimulation.StudentsList.Remove(student);

            if (Order.DeleteOrder(id, tableId))

                return Ok($"Order with ID {id} has been deleted.");
            else
                return NotFound($"Order with ID {id} not found. no rows deleted!");
        }



        [HttpPut("UpdateStatus/{id}/{status}", Name = "UpdateOrderStatus")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<OrderDTO> UpdateOrderStatus(int id, string status)
        {
            if (id < 1 || string.IsNullOrEmpty(status))
            {
                return BadRequest("Invalid Order data.");
            }

            //var student = StudentDataSimulation.StudentsList.FirstOrDefault(s => s.Id == id);

            Order? Order = Order.Find(id); // get


            if (Order == null)
            {
                return NotFound($"Order with ID {id} not found.");
            }

            Order.Status = status;
            Order.Save();

            //we return the DTO not the full student object.
            return Ok(Order.ODTO);

        }


        [HttpGet("TodayReport", Name = "GetTodayReport")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<IEnumerable<ReportDTO>> GetTodayReport()
        {
            List<ReportDTO> report = Order.GetTodayReport();
            if (report.Count == 0)
            {
                return NotFound("No Report Found!");
            }
            return Ok(report); // Returns the list of students.

        }


        [HttpGet("MonthlyReport", Name = "GetMonthlyReport")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<IEnumerable<MonthlyReportDTO>> GetMonthlyReport()
        {
            List<MonthlyReportDTO> report = Order.GetMonthlyReport();
            if (report.Count == 0)
            {
                return NotFound("No Report Found!");
            }
            return Ok(report); // Returns the list of students.

        }

        [HttpGet("YearlyMonthlyRevenue", Name = "GetYearlyMonthlyRevenue")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<IEnumerable<YearlyMonthlyReportDTO>> GetYearlyMonthlyRevenue()
        {
            List<YearlyMonthlyReportDTO> report = Order.GetYearlyMonthlyRevenue();
            if (report.Count == 0)
            {
                return NotFound("No Report Found!");
            }
            return Ok(report); // Returns the list of students.

        }
    }
}
