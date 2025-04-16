using WebApplication1.DataAccess;
using static WebApplication1.DataAccess.ProductData;

namespace WebApplication1.Logic
{
    public class Product
    {
        public enum enMode { AddNew = 0, Update = 1 };
        public enMode Mode = enMode.AddNew;

        public ProductDTO PDTO
        {
            get
            {
                return (new ProductDTO(this.ID, this.Name, this.Price, this.Status));
            }
        }
        public int ID { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
        public string Status { get; set; }

        public Product(ProductDTO PDTO, enMode cMode = enMode.AddNew)
        {
            this.ID = PDTO.Id;
            this.Name = PDTO.Name;
            this.Price = PDTO.Price;
            this.Status = PDTO.Status;
            Mode = cMode;
        }

        private bool _AddNewProduct()
        {
            //call DataAccess Layer 

            this.ID = ProductData.AddProduct(PDTO);

            return (this.ID != -1);
        }

        private bool _UpdateProduct()
        {
            return ProductData.UpdateProduct(PDTO);
        }
        public static List<ProductDTO> GetAllProducts()
        {
            return ProductData.GetAllProducts();
        }

        public static Product? Find(int ID)
        {

            var TDTO = ProductData.GetProductById(ID);

            if (TDTO != null)
            {

                return new Product(TDTO, enMode.Update);
            }
            else
                return null;
        }


        public bool Save()
        {
            switch (Mode)
            {
                case enMode.AddNew:
                    if (_AddNewProduct())
                    {

                        Mode = enMode.Update;
                        return true;
                    }
                    else
                    {
                        return false;
                    }

                case enMode.Update:

                    return _UpdateProduct();

            }

            return false;
        }

        public static bool DeleteProduct(int ID)
        {
            return ProductData.DeleteProduct(ID);
        }
    }
}
