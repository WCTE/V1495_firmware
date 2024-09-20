# This script is called by updateSHA.tcl, which is called by Quartus at the start of compilation.
# It updates the constant "GIT_SHA" to match the most recent git sha

# Get the most recent SHA
SHA=$(git rev-parse --short HEAD)

# Replace the appropriate line in the V1495_regs_pkg file
sed -i "/GIT_SHA/c\  constant GIT_SHA : std_logic_vector(31 downto 0) := x\"0${SHA}\";" src/V1495_regs_pkg.vhd
