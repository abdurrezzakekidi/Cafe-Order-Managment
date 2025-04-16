using WebApplication1.DataAccess;
using static WebApplication1.DataAccess.OrderData;

namespace WebApplication1.Logic
{
    public class Order
    {
        public enum enMode { AddNew = 0, Update = 1 };
        public enMode Mode = enMode.AddNew;

        public OrderDTO ODTO
        {
            get
            {
                return (new OrderDTO(this.Id, this.TableId, this.ProductId, this.Status));
            }
        }
        public int Id { get; set; }
        public int TableId { get; set; }
        public int ProductId { get; set; }
        public string Status { get; set; }


        public Order(OrderDTO ODTO, enMode cMode = enMode.AddNew)
        {
            this.Id = ODTO.Id;
            this.TableId = ODTO.TableId;
            this.ProductId = ODTO.ProductId;
            this.Status = ODTO.Status;

            Mode = cMode;
        }

        private bool _AddNewOrder()
        {
            //call DataAccess Layer 

            this.Id = OrderData.AddOrder(ODTO);

            return (this.Id != -1);
        }

        private bool _UpdateOrder()
        {
            return OrderData.UpdateOrder(ODTO);
        }
        public static List<OrdersDTO> GetAllOrders()
        {
            return OrderData.GetAllOrders();
        }
        public static List<OrderDTO> GetTableOrders(int id)
        {
            return OrderData.GetTableOrders(id);
        }

        public static Order? Find(int ID) // get
        {

            var ODTO = OrderData.GetOrderById(ID);

            if (ODTO != null)
            //we return new object of that student with the right data
            {

                return new Order(ODTO, enMode.Update);
            }
            else
                return null;
        }

        public bool Save()
        {
            switch (Mode)
            {
                case enMode.AddNew:
                    if (_AddNewOrder())
                    {

                        Mode = enMode.Update;
                        return true;
                    }
                    else
                    {
                        return false;
                    }

                case enMode.Update:

                    return _UpdateOrder();

            }

            return false;
        }

        public static bool DeleteOrder(int ID, int tableId)
        {
            return OrderData.DeleteOrder(ID, tableId);
        }

        public static List<ReportDTO> GetTodayReport()
        {
            return OrderData.GetTodayReport();
        }

        public static List<MonthlyReportDTO> GetMonthlyReport()
        {
            return OrderData.GetMonthlyReport();
        }

        public static List<YearlyMonthlyReportDTO> GetYearlyMonthlyRevenue()
        {
            return OrderData.GetYearlyMonthlyRevenue();
        }
    }
}
