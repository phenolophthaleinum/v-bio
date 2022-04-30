<div align="center">
<h1>v-bio</h1>
  <h2>A pure V library with tools for computational molecular biology</h2>

v-bio is a library that provides a set of tools for computational molecular biology purposes. v-bio is heavily based on existing bio tools for [Python](https://www.python.org/) - [biopython](https://github.com/biopython/biopython) (DISCLAIMER: it is not a port). There are many similarities between biopython and v-bio, therefore biopython users should not have any problems with adaptation to v-bio (besides knowing the vlang itself)
</div>

## Installation
### Via vpm

```sh
$ v install phenolophthaleinum.bio
```
or
```sh
$ v install --git --once https://github.com/phenolophthaleinum/v-bio
```
### Via [vpkg](https://github.com/v-pkg/vpkg)
```sh
$ vpkg get https://github.com/phenolophthaleinum/v-bio
```

## Examples
### Import
```v
import phenolophthaleinum.bio
```
### Parsing FASTA file
```v
mut records := bio.parse_fasta('seqs.fna') // parses FASTA file into list of Record objects
println(records[0])
/*
bio.Record{
    id: 'NR_112116.2'
    name: 'NR_112116.2'
'   description: 'Bacillus subtilis strain IAM 12118 16S ribosomal RNA, subseq
    seq:     bio.Seq(TTATCGGAGAGTTTGATCCTGGCTCAGGACGAACGCTGGCGGCGTGCCTAATACATGCAAGTCGAGCGGA
CAGATGGGAGCTTGCTCCCTGATGTTAGCGGCGGACGGGTGAGTAACACGTGGGTAACCTGCCTGTAAGA
CTGGGATAACTCCGGGAAACCGGGGCTAATACCGGATGGTTGTTTGAACCGCATGGTTCAAACATAAAAG
)
}
*/
```
### Sequence tools
```v
mut myseq := bio.Seq('TTATCGGAGAGTTTGATC')
println(myseq.count('GA')) // using built in `count()` - prints `3`
println(myseq.contains_any('N'))) // using built in `contains_any()` - prints `false`
println(myseq.index('TC')?) // using built in `index()` - prints `3`
println(myseq.complement()) // using bio function; returns complementary sequence - `AATAGCCTCTCAAACTAG`
println(myseq.reverse_complement()) // prints `GATCAAACTCTCCGATAA`
println(myseq.transcribe()) // prints `UUAUCGGAGAGUUUGAUC`
println(Seq('T-ATCGGA---TTT-ATC').ungap('-')) // prints `TATCGGATTTATC`
println(myseq.join(["ATA", "CGT"]) // prints `ATATTATCGGAGAGTTTGATCCGTTTATCGGAGAGTTTGATC`
```