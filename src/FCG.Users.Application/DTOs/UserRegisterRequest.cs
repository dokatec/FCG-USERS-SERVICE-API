namespace FCG.Users.Application.DTOs;

public record UserRegisterRequest(string Name, string Email, string Password, string Role);