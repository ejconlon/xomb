// Contains the syscall implementations

module kernel.core.syscall;

import user.syscall;

import kernel.core.error;
import kernel.dev.vga;

import kernel.arch.vmem;

import kernel.environment.scheduler;
import kernel.environment.table;

import kernel.dev.keyboard;

struct SyscallImplementations
{

static:
public:

	// Syscall Implementations

	// add two numbers, a and b, and return the result
	// ulong add(long a, long b)
	SyscallError add(out long ret, AddArgs* params)
	{
		ret = params.a + params.b;
		return SyscallError.OK;
	}

	// void allocPage()
	SyscallError allocPage(out void* ret, AllocPageArgs* params)
	{
		//if(vMem.getUserPage(params.va) == ErrorVal.Success)
		//	ret = SyscallError.OK;
		//else
		//	ret = SyscallError.Failcopter;
		Environment* curEnvironment = Scheduler.getCurrentEnvironment();

		ret = curEnvironment.pageTable.allocPages(1);

		//kprintfln!("allocPage: ret: {x}")(ret);

		return SyscallError.OK;
	}

	// void exit(ulong retval)
	SyscallError exit(ExitArgs* params)
	{

		Scheduler.exit();

		return SyscallError.OK;
	}

	SyscallError freePage(FreePageArgs* params)
	{
		Environment* curEnvironment = Scheduler.getCurrentEnvironment();

		curEnvironment.pageTable.freePages(1);

		return SyscallError.OK;
	}

  	SyscallError yield(YieldArgs* params) {
		Scheduler.yield();

		return SyscallError.OK;
	}

	SyscallError echo(EchoArgs* params) {
		Console.printString(params.str, "");
		return SyscallError.OK;
	}

	SyscallError depositKey(DepositKeyArgs* params) {
		Keyboard.depositKey(params.ch);
		return SyscallError.OK;
	}

	SyscallError initKeyboard(out KeyboardInfo ret, InitKeyboardArgs* params) {
		Environment* curEnvironment = Scheduler.getCurrentEnvironment();

		ubyte* readable;
		ubyte* writeable;

		readable = cast(ubyte*)curEnvironment.pageTable.allocDevicePage(false);
		writeable = cast(ubyte*)curEnvironment.pageTable.allocDevicePage(true);

		curEnvironment.deviceUsage |= Environment.Devices.Keyboard;

		// set values
		ret.writePointer = cast(int*)&readable[0];
		ret.buffer = cast(short*)&readable[long.sizeof];
		ret.bufferLength = vMem.PAGE_SIZE - (long.sizeof);

		ret.readPointer = cast(int*)(&writeable[0]);

		Keyboard.setBuffer(ret.buffer, ret.readPointer, ret.writePointer, ret.bufferLength);

//		Keyboard.setBuffer

		return SyscallError.OK;
	}
}

