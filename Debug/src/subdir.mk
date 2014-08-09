################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/RcppExports.cpp \
../src/ncols.cpp \
../src/printlines.cpp \
../src/readcols.cpp 

OBJS += \
./src/RcppExports.o \
./src/ncols.o \
./src/printlines.o \
./src/readcols.o 

CPP_DEPS += \
./src/RcppExports.d \
./src/ncols.d \
./src/printlines.d \
./src/readcols.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: Cross G++ Compiler'
	g++ -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


