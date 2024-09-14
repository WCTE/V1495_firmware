

SHA=$(git rev-parse --short HEAD)

echo $SHA

sed -i "/GIT_SHA/c\  constant GIT_SHA : std_logic_vector(31 downto 0) := x\"0${SHA}\";" src/V1495_regs_pkg.vhd
