1. Figure out a good system to get decently transactional database migrations with MYSQL.
```
changes = [
  {
    up: {
      add_column: [:api_customer, :encrypted_password, :string, {null: false, default: ""}]
    },
    down: {
      remove_column: [:api_customer, :encrypted_password]
    }
  [:reset_password_token],
  ["datetime", ]
]
```
