using WebApplication1.DataAccess;
using static WebApplication1.DataAccess.TableData;

namespace WebApplication1.Logic
{
    public class Table
    {
        public enum enMode { AddNew = 0, Update = 1 };
        public enMode Mode = enMode.AddNew;

        public TableDTO TDTO
        {
            get
            {
                return (new TableDTO(this.ID, this.No, this.Status));
            }
        }
        public int ID { get; set; }
        public int No { get; set; }
        public string Status { get; set; }

        public Table(TableDTO TDTO, enMode cMode = enMode.AddNew)
        {
            this.ID = TDTO.Id;
            this.No = TDTO.No;
            this.Status = TDTO.Status;

            Mode = cMode;
        }

        private bool _AddNewTable()
        {
            //call DataAccess Layer 

            this.ID = TableData.AddTable(TDTO);

            return (this.ID != -1);
        }

        private bool _UpdateTable()
        {
            return TableData.UpdateTable(TDTO);
        }
        public static List<TableDTO> GetAllTables()
        {
            return TableData.GetAllTables();
        }
        public static List<TableOrdersDTO> GetAllTableOrders(int tableId)
        {
            return TableData.GetAllTableOrders(tableId);
        }

        public static Table? Find(int ID)
        {

            var TDTO = TableData.GetTableById(ID);

            if (TDTO != null)
            {

                return new Table(TDTO, enMode.Update);
            }
            else
                return null;
        }

        public bool Save()
        {
            switch (Mode)
            {
                case enMode.AddNew:
                    if (_AddNewTable())
                    {

                        Mode = enMode.Update;
                        return true;
                    }
                    else
                    {
                        return false;
                    }

                case enMode.Update:

                    return _UpdateTable();

            }

            return false;
        }

        public static bool DeleteTable(int ID)
        {
            return TableData.DeleteTable(ID);
        }

        public static bool PayTableOrders(int ID)
        {
            return TableData.PayTableOrders(ID);
        }
    }
}
