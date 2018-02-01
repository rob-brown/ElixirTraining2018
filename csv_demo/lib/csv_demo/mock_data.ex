defmodule CsvDemo.MockData do
  alias Faker.{Address, Name, Date}
  alias Faker.Phone.EnUs, as: Phone

  def generate_csv(count) do
    Stream.repeatedly(&generate_contact/0)
    |> Stream.take(count)
  end

  def generate_to_file(count, file) do
    with output = file |> Path.expand() |> File.stream!(),
         header = "First Name,Last Name,Phone,Street Address,City,Zip Code,State,Birthday\n" do
      Stream.concat([header], generate_csv(count))
      |> Enum.into(output)
    end
  end

  def generate_contact do
    with components = [
           Name.first_name(),
           Name.last_name(),
           Phone.phone(),
           Address.street_address(),
           Address.city(),
           Address.zip_code(),
           Address.state_abbr(),
           Date.date_of_birth()
         ] do
      components
      |> Enum.map(&to_string/1)
      |> Enum.join(",")
      |> (&(&1 <> "\n")).()
    end
  end
end
