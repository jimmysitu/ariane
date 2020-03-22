# Configure IP parameters
set root_path [ file dirname [ file normalize [ info script ] ] ]
puts $root_path

source $root_path/config.tcl

# Create IP
source $root_path/create_ip.tcl
