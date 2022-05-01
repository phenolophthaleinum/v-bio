// Module bio implements Record and Sequence management
module bio

import os

// Alias for string type, used to represent the sequence.
type Seq = string

// Record struct defines id of a record, name of a record,
// description of a record and holds Seq object.
pub struct Record {
pub mut:
	id          string
	name        string
	description string
	seq         Seq
}

pub struct CodonTable
{
pub:
	id int
	name string
	table map[string]string
	start_codons []string
	stop_codons []string
}

// Returns complement sequence as a string/Seq.
// Example: bio.Seq('ATAGCAT').complement() // prints: 'TATCGTA'
pub fn (mut s Seq) complement() string {
	complements := {
		'A': 'T'
		'T': 'A'
		'G': 'C'
		'C': 'G'
	}
	mut seq_split := s.split('')
	for i, base in seq_split {
		seq_split[i] = complements[base]
	}

	// r.seq = seq_split.join('')
	return seq_split.join('')
}

// Returns reverse complement sequence as a string/Seq.
// Example: bio.Seq('ATAGCAT').reverse_complement() // prints: 'ATGCTAT'
pub fn (mut s Seq) reverse_complement() string {
	return s.complement().reverse()
}

// Returns transcribed sequence as a string/Seq.
// Example: bio.Seq('ATAGCAT').transcribe() // prints: 'AUAGCAU'
pub fn (mut s Seq) transcribe() string {
	return s.replace('T', 'U')
}

pub fn (mut s Seq) translate(c_table CodonTable, stop_sign string, to_stop bool, cds bool, gap string) string 
{
	seq := s.to_upper()
	n := seq.len
	mut aa := []string{}

	// check for ambiguity
	duals := c_table.stop_codons.filter(it in c_table.table)
	if duals.len > 0 {
		if to_stop == true {
			panic("Translation Error: cannot use 'to_stop=true' with this table since it contains following ambiguous codons: ${duals}. These can be both STOP and an amino acid.")
		}
		println("Translation Warning: this table contains following ambiguous codons: ${duals}. These can be both STOP and an amino acid but will be translated as amino acid.")
	}

	// cds checks
	if cds == true {
		if seq[0..3] !in c_table.start_codons {
			panic("Translation Error: first codon ${seq[0..3]} is not a start codon.")
		}
		if n % 3 != 0 {
			panic("Translation Error: sequence of a length ${n} is not a multiple of three.")
		}
		if seq[n - 3..n] !in c_table.stop_codons {
			panic("Translation Error: last codon ${seq[0..3]} is not a stop codon.")
		}
		seq = seq[3..n - 3]
		n -= 6
		aa << 'M'
	}

	// gap checks
	if gap != '' {
		if gap.len > 1 {
			panic("Translation Error: gap character must be a single character.")
		}
	}

	for i in int_range(start:0, stop: n - n % 3, step: 3)
	{
		c := seq[i..i + 3]
		if c in c_table.table {
			aa << c_table.table[c]
		}
		else {
			if c in c_table.stop_codons {
				if cds == true {
					panic("Translation Error: additional stop codon in frame.")
				}
				if to_stop == true {
					break
				}
				aa << stop_sign
			}
			else if gap != '' && c == gap.repeat(3) {
				aa << gap
			}
			else {
				panic("Translation Error: codon is invalid according to used codon table.")
			}
		}
	}
	return aa.join("")
}

// Returns ugapped sequence as a string/Seq. The gap character must be provided.
// Example: bio.Seq('ATA--TC-A').ungap('-') // prints: 'ATATCA'
pub fn (mut s Seq) ungap(gap string) string {
	return s.replace(gap, '')
}

// Returns merged sequences, spaced by the sequence from which the function was called.
// Example: bio.Seq("NNN").join(["ATA", "CGT"]) // prints: ATANNNCGTNNN
pub fn (s Seq) join(seqs []string) string {
	mut res := []string{}
	for e in seqs {
		res << [e, s]
	}
	return res.join('')
}

// Maps list of Records into dictionary.
pub fn to_dict(records []Record) map[string]Record {
	mut d := map[string]Record{}
	for rec in records {
		key := rec.id
		if key in d {
			panic("Duplicate key '$key'")
		}
		d[key] = rec
	}
	return d
}

pub fn safe_join(list []string, joiner string) ?string {
	return list.join(joiner)
}

pub fn parse_fasta(filename string) []Record {
	mut records := []Record{}
	file := os.read_file(filename) or {
		panic('Failed to read file <$filename>.')
		return records
	}
	lines := file.split('\n')
	mut sequence := ''
	mut seq_id := ''
	mut seq_name := ''
	mut desc := ''
	mut header_idx := []int{}
	for line in lines {
		if line.starts_with('>') {
			header_idx << lines.index(line)
		}
	}
	for idx in header_idx {
		sequence = ''
		mut sequence_slice := []string{}
		header := lines[idx].split(' ')
		seq_id = header[0].replace('>', '')
		seq_name = header[0].replace('>', '')
		desc = safe_join(header[1..header.len], ' ') or {
			desc = '<unknown description>'
			continue
		}
		if header_idx.index(idx) + 1 >= header_idx.len {
			sequence_slice = lines[idx + 1..lines.len]
			sequence = sequence_slice.join('')
			records << Record{
				id: seq_id
				seq: sequence
				name: seq_name
				description: desc
			}
			return records
		}
		sequence_slice = lines[idx + 1..header_idx[header_idx.index(idx) + 1]]
		sequence = sequence_slice.join('')
		records << Record{
			id: seq_id
			seq: sequence
			name: seq_name
			description: desc
		}
	}
	return records
}

pub fn parse_fasta2(filename string) []Record {
	mut records := []Record{}
	file := os.read_file(filename) or {
		panic('Failed to read file <$filename>.')
		return records
	}
	lines := file.split('>')[1..]
	mut sequence := ''
	mut seq_id := ''
	mut seq_name := ''
	mut desc := ''
	for line in lines {
		first_nl := line.index('\n') or {
			panic('Failed to parse FASTA file <$filename>.')
			return records
		}
		header := line[0..first_nl]
		seq_id = header.all_before(' ')
		seq_name = seq_id
		desc = header.all_after(' ')
		if desc.len == header.len {
			desc = '<unknown description>'
		}
		sequence = line[first_nl + 1..line.len]
		records << Record{
			id: seq_id
			seq: sequence
			name: seq_name
			description: desc
		}
	}
	return records
}
