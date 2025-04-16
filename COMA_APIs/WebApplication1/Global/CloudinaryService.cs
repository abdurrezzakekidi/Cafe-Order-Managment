using CloudinaryDotNet;
using CloudinaryDotNet.Actions;

namespace WebApplication1.Global
{
    public class CloudinaryService
    {
        public static async Task<string> UploadImageAsync(IFormFile file)
        {
            Cloudinary cloudinary;
            var acc = new Account(CloudinarySettings.CloudName, CloudinarySettings.ApiKey, CloudinarySettings.ApiSecret);
            cloudinary = new Cloudinary(acc);


            var uploadResult = new ImageUploadResult();

            if (file.Length > 0)
            {
                using (var stream = file.OpenReadStream())
                {
                    var uploadParams = new ImageUploadParams()
                    {
                        File = new FileDescription(file.FileName, stream)
                    };

                    uploadResult = await cloudinary.UploadAsync(uploadParams);
                }
            }

            return uploadResult.Url.ToString();
        }

        public static async Task<string> ReplaceImageAsync(IFormFile file, string existingImageUrl)
        {
            Cloudinary cloudinary;
            var acc = new Account(CloudinarySettings.CloudName, CloudinarySettings.ApiKey, CloudinarySettings.ApiSecret);
            cloudinary = new Cloudinary(acc);

            // Extract the public ID from the existing URL
            var publicId = GetPublicIdFromUrl(existingImageUrl);

            if (!string.IsNullOrEmpty(publicId))
            {
                // Delete the existing image
                var deletionParams = new DeletionParams(publicId);
                await cloudinary.DestroyAsync(deletionParams);
            }

            // Upload the new image
            return await UploadImageAsync(file);
        }

        private static string GetPublicIdFromUrl(string url)
        {
            try
            {
                // Check if the URL is valid
                if (!Uri.IsWellFormedUriString(url, UriKind.Absolute))
                {
                    Console.WriteLine("Geçersiz URL formatı.");
                    return string.Empty;
                }

                var uri = new Uri(url);
                var segments = uri.Segments;

                if (segments.Length == 0)
                {
                    Console.WriteLine("URL parçaları bulunamadı.");
                    return string.Empty;
                }

                var publicIdWithExtension = segments.Last(); // e.g., "sample.jpg"
                if (!publicIdWithExtension.Contains('.'))
                {
                    Console.WriteLine("Dosya uzantısı bulunamadı.");
                    return string.Empty;
                }

                var publicId = publicIdWithExtension.Substring(0, publicIdWithExtension.LastIndexOf('.'));
                return publicId;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Hata: {ex.Message}");
                return string.Empty;
            }
        }


        public static async Task<bool> DeleteImageAsync(string imageUrl)
        {
            Cloudinary cloudinary;
            var acc = new Account(CloudinarySettings.CloudName, CloudinarySettings.ApiKey, CloudinarySettings.ApiSecret);
            cloudinary = new Cloudinary(acc);

            // Extract the public ID from the existing URL
            var publicId = GetPublicIdFromUrl(imageUrl);

            // Delete the image from Cloudinary
            var deletionParams = new DeletionParams(publicId);
            var deletionResult = await cloudinary.DestroyAsync(deletionParams);

            return deletionResult.Result == "ok";
        }

        public static async Task<bool> DeleteImagesAsync(string[] imageUrl)
        {
            for (int i = 0; i < imageUrl.Length; i++)
            {
                if (!await DeleteImageAsync(imageUrl[i]))
                    return false;
            }

            return true;
        }

        public static async Task<List<string>> ReplaceImagesAsync(List<string> existingImageUrls, List<IFormFile> newFiles)
        {
            Cloudinary cloudinary;
            var acc = new Account(CloudinarySettings.CloudName, CloudinarySettings.ApiKey, CloudinarySettings.ApiSecret);
            cloudinary = new Cloudinary(acc);


            // Silme işlemleri
            var deleteTasks = existingImageUrls.Select(url =>
            {
                var publicId = GetPublicIdFromUrl(url);
                var deletionParams = new DeletionParams(publicId);
                return cloudinary.DestroyAsync(deletionParams);
            });

            // Silme işlemlerini bekleme
            await Task.WhenAll(deleteTasks);

            // Yükleme işlemleri
            var uploadTasks = newFiles.Select(file =>
            {
                var uploadParams = new ImageUploadParams
                {
                    File = new FileDescription(file.FileName, file.OpenReadStream())
                };
                return cloudinary.UploadAsync(uploadParams);
            });

            // Yükleme işlemlerini bekleme ve yeni URL'leri toplama
            var uploadResults = await Task.WhenAll(uploadTasks);

            return uploadResults.Select(result => result.Url.ToString()).ToList();
        }
        public static async Task<List<string>> UploadImagesAsync(List<IFormFile> files)
        {
            Cloudinary cloudinary;
            var acc = new Account(CloudinarySettings.CloudName, CloudinarySettings.ApiKey, CloudinarySettings.ApiSecret);
            cloudinary = new Cloudinary(acc);


            var uploadTasks = files.Select(file =>
            {
                var uploadParams = new ImageUploadParams
                {
                    File = new FileDescription(file.FileName, file.OpenReadStream())
                };
                return cloudinary.UploadAsync(uploadParams);
            });

            var uploadResults = await Task.WhenAll(uploadTasks);

            return uploadResults.Select(result => result.Url.ToString()).ToList();
        }
    }
}
