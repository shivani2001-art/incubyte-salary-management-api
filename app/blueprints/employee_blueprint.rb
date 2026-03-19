class EmployeeBlueprint < Blueprinter::Base
  identifier :id

  fields :full_name, :job_title, :country, :salary
end
