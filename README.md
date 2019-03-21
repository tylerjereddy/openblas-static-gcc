Experimental OpenBLAS Builds that statically link in GCC runtime
----------------------------------------------------------------

Aim is to avoid Windows DLL search scenarios at NumPy runtime where gfortran and related library searching can be fragile. Try to just bake them in to the OpenBLAS library we normally produce by static linking.
