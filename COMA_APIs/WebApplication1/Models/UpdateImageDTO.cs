namespace WebApplication1.Models
{
    public class UpdateImageDTO
    {
        public int Id { get; set; }
        public string OldImagePath { get; set; }
        public IFormFile NewImage { get; set; }
    }
}
