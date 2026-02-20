final: prev: {
  pythonPackagesExtensions =
    (prev.pythonPackagesExtensions or [ ])
    ++ [
      (pyFinal: pyPrev: import ../pkgs/python {
        python = pyFinal;
        pythonPrev = pyPrev;
      })
    ];
}
