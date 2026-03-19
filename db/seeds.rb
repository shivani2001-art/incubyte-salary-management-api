user = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "password123"
end
puts "Default user: admin@example.com / password123"

employees = [
  { full_name: "Aarav Sharma", job_title: "Engineer", country: "India", salary: 75_000 },
  { full_name: "Priya Patel", job_title: "Engineer", country: "India", salary: 82_000 },
  { full_name: "Rahul Gupta", job_title: "Manager", country: "India", salary: 95_000 },
  { full_name: "John Smith", job_title: "Engineer", country: "United States", salary: 120_000 },
  { full_name: "Sarah Johnson", job_title: "Manager", country: "United States", salary: 140_000 },
  { full_name: "Emily Davis", job_title: "Designer", country: "United States", salary: 105_000 },
  { full_name: "Hans Mueller", job_title: "Engineer", country: "Germany", salary: 85_000 },
  { full_name: "Anna Schmidt", job_title: "Designer", country: "Germany", salary: 78_000 }
]

employees.each do |attrs|
  Employee.find_or_create_by!(full_name: attrs[:full_name]) do |e|
    e.job_title = attrs[:job_title]
    e.country = attrs[:country]
    e.salary = attrs[:salary]
  end
end

puts "Seeded #{Employee.count} employees"
