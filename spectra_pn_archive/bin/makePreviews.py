from gavo import api

class PreviewMaker(api.SpectralPreviewMaker):
  sdmId = "build_spectrum"
  linearFluxes = True

if __name__=="__main__":
  api.procmain(PreviewMaker, "spectra_pn_archive/q", "import")
