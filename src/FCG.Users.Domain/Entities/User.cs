using System.Text.RegularExpressions;

namespace FCG.Users.Domain.Entities
{
    public class User
    {
        public Guid Id { get; private set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string Role { get; set; }


        public User(string name, string email, string password, string role)
        {
            if (string.IsNullOrWhiteSpace(password) || !ValidatePassword(password))
                throw new ArgumentException("A senha deve ter no mínimo 8 caracteres, incluir números e símbolos.");

            ValidateEmail(email);
            ValidatePassword(password);

            Id = Guid.NewGuid();
            Name = name;
            Email = email;
            Password = password;
            Role = role;
        }

        private void ValidateEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                throw new ArgumentException("Email é obrigatório.");

            var emailPattern = @"^[^@\s]+@[^@\s]+\.[^@\s]+$";
            if (!Regex.IsMatch(email, emailPattern))
                throw new ArgumentException("Email inválido.");
        }

        private bool ValidatePassword(string password)
        {
            var regex = new Regex(@"^(?=.*[0-9])(?=.*[!@#$%^&*])(?=.{8,})");
            return regex.IsMatch(password);
        }

        public User()
        {
            Name = string.Empty;
            Email = string.Empty;
            Password = string.Empty;
            Role = string.Empty;
        }
    }
}