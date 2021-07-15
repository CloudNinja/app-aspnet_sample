# tags
variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resoruces that are deployed with this module."

  default = {
    owner        = "Michel Bechelani"
    project      = "ASPNET Sample"
    created_date = "2021-07-15"
  }
}
