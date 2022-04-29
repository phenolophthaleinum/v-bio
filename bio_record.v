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

// Returns complement sequence as a string/Seq.
// Example: 'ATAGCAT' -> 'TATCGTA'
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
// Example: 'ATAGCAT' -> 'ATGCTAT'
pub fn (mut s Seq) reverse_complement() string {
	return s.complement().reverse()
}

// Returns transcribed sequence as a string/Seq.
// Example: 'ATAGCAT' -> 'AUAGCAU'
pub fn (mut s Seq) transcribe() string {
	return s.replace('T', 'U')
}

// Returns ugapped sequence as a string/Seq. The gap character must be provided.
// Example: 'ATA--TC-A' -> 'ATATCA'
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
