using FCG.Users.Application.DTOs;
using FCG.Users.Application.Interfaces;
using FCG.Users.Domain.Entities;
using FCG.Users.Domain.Interfaces;
using FCG.Shared.Events;
using MassTransit;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization; // Necessário para [Authorize]

namespace FCG.Users.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UserController : ControllerBase
{
    private readonly IUserRepository _userRepository;
    private readonly IAuthService _authService;
    private readonly IPublishEndpoint _publishEndpoint;

    public UserController(IUserRepository userRepository, IAuthService authService, IPublishEndpoint publishEndpoint)
    {
        _userRepository = userRepository;
        _authService = authService;
        _publishEndpoint = publishEndpoint;
    }

    // Aberto a todos (Público)
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] UserRegisterRequest request)
    {
        try
        {
            var existingUser = await _userRepository.GetByEmailAsync(request.Email);
            if (existingUser != null) return BadRequest("Este e-mail já está em uso.");

            var user = new User(request.Name, request.Email, request.Password, request.Role);
            user.Password = BCrypt.Net.BCrypt.HashPassword(request.Password);

            await _userRepository.AddAsync(user);

            await _publishEndpoint.Publish<IUserCreatedEvent>(new
            {
                UserId = user.Id,
                Name = user.Name,
                Email = user.Email,
                CreatedAt = DateTime.UtcNow
            });

            return Ok(new { Message = "Usuário registrado com sucesso." });
        }
        catch (ArgumentException ex) { return BadRequest(ex.Message); }
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] UserLoginRequest request)
    {
        var user = await _userRepository.GetByEmailAsync(request.Email);
        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.Password))
            return Unauthorized("E-mail ou senha inválidos.");

        var token = _authService.GenerateToken(user.Email, user.Role);
        return Ok(new { token });
    }

    // --- ÁREA ADMINISTRATIVA (Somente Admin) ---

    [HttpGet]
    [Authorize(Roles = "Admin")] // Somente quem tem a Role Admin acessa
    public async Task<IActionResult> GetAll()
    {
        var users = await _userRepository.GetAllAsync();
        return Ok(users);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UserRegisterRequest request)
    {
        var user = await _userRepository.GetByIdAsync(id);
        if (user == null) return NotFound("Usuário não encontrado.");

        user.Name = request.Name;
        user.Email = request.Email;
        user.Role = request.Role;

        if (!string.IsNullOrEmpty(request.Password))
            user.Password = BCrypt.Net.BCrypt.HashPassword(request.Password);

        await _userRepository.UpdateAsync(user);
        return Ok(new { Message = "Usuário atualizado com sucesso." });
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var user = await _userRepository.GetByIdAsync(id);
        if (user == null) return NotFound("Usuário não encontrado.");

        await _userRepository.DeleteAsync(id);
        return Ok(new { Message = "Usuário removido com sucesso." });
    }
}