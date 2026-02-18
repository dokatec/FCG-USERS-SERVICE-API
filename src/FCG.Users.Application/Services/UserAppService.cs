using FCG.Users.Application.DTOs;
using FCG.Users.Domain.Entities;
using FCG.Users.Domain.Interfaces;

namespace FCG.Users.Application.Services;

public class UserAppService
{
    private readonly IUserRepository _repository;
    public UserAppService(IUserRepository repository) => _repository = repository;

    public async Task Register(UserRegisterRequest request)
    {
        // Aqui você usaria sua lógica de Hash de senha que já deve ter da fase anterior
        var user = new User(request.Name, request.Email, request.Password, request.Role);
        await _repository.AddAsync(user);
    }
}