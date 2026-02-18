namespace FCG.Users.Application.Interfaces;

public interface IAuthService
{
    string GenerateToken(string email, string role);
}