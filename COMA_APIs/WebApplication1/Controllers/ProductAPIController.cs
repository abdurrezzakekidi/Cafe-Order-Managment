using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using WebApplication1.Logic;
using static WebApplication1.DataAccess.ProductData;

namespace WebApplication1.Controllers
{
    [Route("api/Products")]
    [ApiController]
    public class ProductAPIController : ControllerBase
    {
        [HttpGet("All", Name = "GetAllProducts")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<IEnumerable<ProductDTO>> GetAllProducts()
        {
            List<ProductDTO> ProductsList = Product.GetAllProducts();
            if (ProductsList.Count == 0)
            {
                return NotFound("No Products Found!");
            }
            return Ok(ProductsList); // Returns the list of students.
        }


        //[HttpGet("{id}", Name = "GetProductById")]
        //[ProducesResponseType(StatusCodes.Status200OK)]
        //[ProducesResponseType(StatusCodes.Status400BadRequest)]
        //[ProducesResponseType(StatusCodes.Status404NotFound)]
        //public ActionResult<ProductDTO> GetProductById(int id)
        //{

        //    if (id < 1)
        //    {
        //        return BadRequest($"Not accepted ID {id}");
        //    }


        //    COMABusinessLayer.Product Product = COMABusinessLayer.Product.Find(id);

        //    if (Product == null)
        //    {
        //        return NotFound($"Product with ID {id} not found.");
        //    }

        //    //here we get only the DTO object to send it back.
        //    ProductDTO TDTO = Product.PDTO;

        //    //we return the DTO not the student object.
        //    return Ok(TDTO);

        //}


        [HttpPost(Name = "AddProduct")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public ActionResult<ProductDTO> AddProduct(ProductDTO newProductDTO)
        {
            //we validate the data here
            if (newProductDTO == null || string.IsNullOrEmpty(newProductDTO.Status) || string.IsNullOrEmpty(newProductDTO.Status)
                || newProductDTO.Price <0 || newProductDTO.Price < 0)
            {
                return BadRequest("Invalid Product data.");
            }

            //newStudent.Id = StudentDataSimulation.StudentsList.Count > 0 ? StudentDataSimulation.StudentsList.Max(s => s.Id) + 1 : 1;

            Product Product = new Product(new ProductDTO(newProductDTO.Id, newProductDTO.Name, newProductDTO.Price, newProductDTO.Status));
            if (Product.Save())
                return Ok();
            else
                return NotFound();
        }

        [HttpPut("{id}", Name = "UpdateProduct")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<ProductDTO> UpdateStudent(int id, ProductDTO updatedProduct)
        {
            if (id < 1 || updatedProduct == null || string.IsNullOrEmpty(updatedProduct.Status) || string.IsNullOrEmpty(updatedProduct.Status)
                || updatedProduct.Price <0 || updatedProduct.Price < 0)
            {
                return BadRequest("Invalid Product data.");
            }

            //var student = StudentDataSimulation.StudentsList.FirstOrDefault(s => s.Id == id);

            Product? Product = Product.Find(id);


            if (Product == null)
            {
                return NotFound($"Product with ID {id} not found.");
            }


            Product.Name = updatedProduct.Name;
            Product.Price = updatedProduct.Price;
            Product.Status = updatedProduct.Status;
            Product.Save();

            //we return the DTO not the full student object.
            return Ok(Product.PDTO);

        }


        [HttpDelete("{id}", Name = "DeleteProduct")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult DeleteProduct(int id)
        {
            if (id < 1)
            {
                return BadRequest($"Not accepted ID {id}");
            }

            if (Product.DeleteProduct(id))

                return Ok($"Product with ID {id} has been deleted.");
            else
                return NotFound($"Product with ID {id} not found. no rows deleted!");
        }
    }
}
