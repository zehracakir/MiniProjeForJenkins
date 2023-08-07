using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;

namespace MiniProje.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ScreenController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public ScreenController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [HttpGet] // GET isteği
        public IActionResult Get()
        {
            // ENV'deki degeri al
            string sirketAdi = _configuration["APP_DATA_SIRKET"];
            string calisanAdi = _configuration["APP_DATA_CALISAN"];

            if (string.IsNullOrEmpty(sirketAdi) || string.IsNullOrEmpty(calisanAdi))
            {
                // ENV boşsa ya da yoksa hata döndür
                return NotFound("ENV bulunamadı veya boş");
            }

            // ENV'den alınan veriyi JSON olarak döndür
            return Ok(new { Data = sirketAdi + " " + calisanAdi });
        }
    }
}
