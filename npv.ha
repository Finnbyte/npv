use fmt;
use strconv;
use ascii;
use time;
use time::date;
use regex;
use strings;
use os;

fn search_entry_for_name(name: str) nullable *Entry = {
	for (let entry .. NAMEDATES) {
		if (strings::contains(ascii::strlower(entry[1]),  ascii::strlower(name))) {
			return &entry;
		};
	};
	return null;
};

fn search_entries_for_dates(dates: []str) nullable *[]Entry = {
	let matches: []Entry = [];
	for (const d .. dates) {
		for (const entry .. NAMEDATES) {
			if (entry[0] == d) {
				append(matches, entry);
				break;
			};
			const entryDateParts =  strings::split(entry[0], ".");
			const dParts =  strings::split(d, ".");
			const matchesDate = dParts[0] == "x" || dParts[0] == entryDateParts[0];
			const matchesMonth = dParts[1] == "x" || dParts[1] == entryDateParts[1];
			if (matchesDate && matchesMonth) {
				append(matches, entry);
			};

		};
	};
	if (len(matches) > 0) {
		return &matches;
	} else {
		return null;
	};
};

fn print_entry(entry: Entry) void = {
	fmt::printfln("{}: {}", entry[0], entry[1])!;
};

fn print_entries(entries: []Entry) void = {
	for (const entry .. entries) {
		print_entry(entry);
	};
};

fn error(message: str) void = {
	fmt::println(message)!;
	os::exit(1);
};

fn normalize_input_date(input: str) str = {
	let parts = strings::split(input, ".");

	if (len(parts) == 1) {
		append(parts, "x");
	};

	for (let i: size = 0; i < len(parts); i += 1) {
		if (parts[i] != "x") parts[i] = strings::lpad(parts[i], '0', 2);
	};

	const date = fmt::asprintf("{}.{}", parts[0], parts[1]);
	return date;
};

fn no_entries(input_arg: str) void = {
	fmt::printfln("No entries for {}", input_arg)!;
};

fn is_date(input: str) bool = {
	let iter = strings::iter(input);
	let ch: (rune | done) = strings::next(&iter);
	let allRunesAreDigits = true; // all runes excludes dots and x's
	let dotCount = 0;
	let xCount = 0;
	for (!(ch is done)) {
		if (ch == '.') {
			dotCount += 1;
		} else if (ch == 'x') {
			xCount += 1;
		} else if (!ascii::isdigit(ch as rune)) {
			allRunesAreDigits = false;
		};

		ch = strings::next(&iter);
	};

	return (allRunesAreDigits == true && xCount == 0 && (dotCount >= 0 && dotCount <= 1)) || (dotCount == 1 && (xCount > 0 && xCount <= 2));
};

export fn main() void = {
	const args = os::args;
	if (len(args) == 1) {
		const current = date::now();
		const day = date::day(&current);
		const month = date::month(&current);
		let target_dates: []str = [];
		for (let i = 0; i < 7; i += 1) {
			const d = date::add(current, i * time::HOUR * 24);
			const dd = date::day(&d);
			const m = strconv::itos(date::month(&d));

			const formatted_date = fmt::asprintf("{}.{}", dd, m);
			append(target_dates, formatted_date);
		};

		const matches = search_entries_for_dates(target_dates);
		if (!(matches is null)) {
			print_entries(*(matches as *[]Entry));
		} else {
			no_entries("week");
		};

		return;
	};

	const input = args[1];

	if (!is_date(input)) {
		const entry = search_entry_for_name(input);
		if (!(entry is null)) {
			print_entry(*(entry as *Entry));
		} else {
			no_entries(input);
		};
		return;
	};

	const date = normalize_input_date(input);
	const matches = search_entries_for_dates([date]);
	if (!(matches is null)) {
		print_entries(*((matches as *[]Entry)));
	} else {
		no_entries(date);
	};
};
