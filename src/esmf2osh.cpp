#include <Omega_h_library.hpp>
#include <Omega_h_esmfWrapper.h>
#include <Omega_h_cmdline.hpp>
#include <Omega_h_build.hpp>
#include <Omega_h_file.hpp>
#include <Omega_h_for.hpp>
#include <sstream>
#include <iostream>

namespace oh = Omega_h;

int fileTypeStringToInt(std::string fileType) {
  assert(fileType == "scrip" || fileType == "esmf" || fileType == "ugrid");
  if(fileType == "scrip") return 2;
  if(fileType == "esmf") return 3;
  if(fileType == "ugrid") return 5;
  else return 0; //UNKNOWN
}

int main(int argc, char** argv) {
  auto lib = Omega_h::Library(&argc, &argv);
  auto comm = lib.world();
  Omega_h::CmdLine cmdline;
  cmdline.add_arg<std::string>("input.osh");
  cmdline.add_arg<std::string>("output.osh");
  auto& fileTypeFlag = cmdline.add_flag("--in-mesh-type", "scrip|esmf|ugrid");
  fileTypeFlag.add_arg<std::string>("type");
  if (!cmdline.parse(comm, &argc, argv) ||
      !Omega_h::CmdLine::check_empty(comm, argc, argv)) {
    cmdline.show_help(comm, argv);
    return -1;
  }
  auto inpath = cmdline.get<std::string>("input.osh");
  auto outpath = cmdline.get<std::string>("output.osh");
  auto fileTypeString = cmdline.get<std::string>("--in-mesh-type", "type");
  auto fileType = fileTypeStringToInt(fileTypeString);
  esmfInit();
  std::string meshFileName(argv[1]);
  esmfLoadMesh(inpath.c_str(), inpath.length(), fileType);
  int dim, numVerts, numElms;
  esmfGetMeshInfo(&dim, &numVerts, &numElms);
  std::cout << "dim, numVerts, numElms: "
            << dim << ", " << numVerts << ", " << numElms << "\n";

  oh::HostWrite<oh::Real> coords(numVerts*dim);
  oh::HostWrite<oh::LO> vtxIdsEsmf(numVerts);
  oh::HostWrite<oh::LO> elemVertsEsmf(numElms*3);
  esmfGetMeshVtxCoords(coords.data());
  esmfGetMeshVtxIds(vtxIdsEsmf.data());
  esmfGetMeshElemVerts(elemVertsEsmf.data());

  //create element-to-vtx device array
  //the esmf 'elemVerts' array contains indices into the array of vertex ids
  //the esmf vertex ids start at one instead of zero
  auto coords_d = oh::read(coords.write());
  auto vtxIdsEsmf_d = oh::read(vtxIdsEsmf.write());
  auto elemVertsEsmf_d = oh::read(elemVertsEsmf.write());

  oh::Write<oh::LO> elemVertsOh_d(numElms*3);
  auto setConnectivity = OMEGA_H_LAMBDA(oh::LO i) {
    elemVertsOh_d[i] = vtxIdsEsmf_d[elemVertsEsmf_d[i]-1] - 1;
  };
  oh::parallel_for(elemVertsOh_d.size(), setConnectivity);

  auto mesh = oh::Mesh(&lib);
  oh::build_from_elems_and_coords(&mesh, OMEGA_H_SIMPLEX, 2,
      elemVertsOh_d, coords_d);
  oh::binary::write(outpath, &mesh);

  esmfFinalize();
  return 0;
}