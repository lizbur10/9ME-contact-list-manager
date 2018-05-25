# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
DATA_managers = {
    :manager_keys =>
        ["name", "contact_info", "market"],
    :managers => [
        ['Matt', '??', 'Albany'],
        ['Tyler', 'tylerspangenberg@gmail.com', 'Albany'],
        ['TJ', '??', 'Albany'],
        ['Lyssa', '??', 'Albany'],
        ['Gordon', 'gordon@9mileseast.com', 'Boston'],
        ['Nick', 'nick@9mileseast.com', 'Boston'],
        ['Sarah', 'smvkoo@gmail.com', 'Boston'],
        ['Matt W', 'matthew.f.watson2@gmail.com', 'Boston'],
        ['Elli', 'ellijlevy@gmail.com', 'Boston'],
        ['Liz', 'liz.burton147@gmail.com', 'Boston']
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
