# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
DATA_managers = {
    :manager_keys =>
        ["name", "contact_info", "market", "role"],
    :managers => [
        ['Matt', '??', 'Albany', 'user'],
        ['Tyler', 'tylerspangenberg@gmail.com', 'Albany', 'user'],
        ['TJ', '??', 'Albany', 'user'],
        ['Lyssa', '??', 'Albany', 'user'],
        ['Gordon', 'gordon@9mileseast.com', 'Boston', 'user'],
        ['Nick', 'nick@9mileseast.com', 'Boston', 'user'],
        ['Sarah', 'smvkoo@gmail.com', 'Boston', 'user'],
        ['Matt W', 'matthew.f.watson2@gmail.com', 'Boston', 'user'],
        ['Elli', 'ellijlevy@gmail.com', 'Boston', 'user'],
        ['Liz', 'liz.burton147@gmail.com', 'Boston', 'admin']
    ]
}

def make_managers
    DATA_managers[:managers].each do |manager|
        new_manager = Manager.new
        manager.each_with_index do |attribute, i|
            new_manager.send(DATA_managers[:manager_keys][i]+"=", attribute)
        end
        new_manager.save
    end
end

make_managers
