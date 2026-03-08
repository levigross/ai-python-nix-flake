{
  python,
  pythonPrev ? python,
}:
(import ./deps.nix {inherit python pythonPrev;})
// (import ./frameworks.nix {inherit python pythonPrev;})
